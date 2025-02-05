# frozen_string_literal: true

require "spec_helper"
require "date"

RSpec.describe AccessorHooks do
  describe "after_change" do
    context "with simple hook" do
      let(:klass) do
        Class.new do
          include AccessorHooks
          attr_reader :full_name
          attr_accessor :first_name, :second_name

          after_change :update_full_name, on: %i[first_name second_name]

          private

          def update_full_name = @full_name = [first_name, second_name].join(" ").strip
        end
      end

      let(:entity) { klass.new }

      it {
        expect { entity.first_name = "Ivan" }.to change(entity, :full_name).to "Ivan"
        expect { entity.second_name = "Ivanov" }.to change(entity, :full_name).to "Ivan Ivanov"
      }
    end

    context "when hook has new attribute value as param" do
      let(:klass) do
        Class.new do
          include AccessorHooks
          attr_reader :full_name
          attr_accessor :name

          after_change :update_full_name, on: :name

          private

          def update_full_name(name) = @full_name = "#{name}.pdf"
        end
      end

      let(:entity) { klass.new }

      it { expect { entity.name = "file" }.to change(entity, :full_name).to "file.pdf" }
    end
  end

  describe "before_change" do
    context "with simple hook" do
      let(:klass) do
        Class.new do
          include AccessorHooks
          attr_reader :full_name
          attr_accessor :name

          before_change :clear_full_name, on: :name

          private

          def clear_full_name
            @full_name = ""
          end
        end
      end

      let(:entity) { klass.new }

      it {
        expect(entity.name).to be_nil
        expect { entity.name = "Ivan" }.to change(entity, :full_name).to be_empty
      }
    end
  end

  context "when using after_change and before_change" do
    context "and defining each of them" do
      let(:klass) do
        Class.new do
          include AccessorHooks

          attr_reader :ids
          attr_accessor :id

          before_change :check_id, on: :id
          after_change :add_id, on: :id

          def initialize = @ids = []

          private

          def check_id(value)
            raise StandardError if value < 0
          end

          def add_id = @ids << @id
        end
      end

      let(:entity) { klass.new }

      it { expect { entity.id = -1 }.to raise_error(StandardError) }
      it { expect { entity.id = 1 }.to change(entity.ids, :count).by(1) }
    end

    context "and defining hooks separately" do
      let(:klass) do
        Class.new do
          include AccessorHooks
          attr_reader :updated_at
          attr_accessor :name, :created_at, :user, :status

          after_change :update_updated_at, on: :name
          after_change :update_updated_at, on: :created_at
          before_change :update_name, on: :status
          after_change :update_updated_at, on: :user

          private

          def update_updated_at = @updated_at = DateTime.now
          def update_name(status) = @name = status
        end
      end

      let(:entity) { klass.new }

      it { expect { entity.name = "file" }.to change(entity, :updated_at) }
      it { expect { entity.created_at = DateTime.now }.to change(entity, :updated_at) }
      it { expect { entity.status = "ok" }.to change(entity, :name).to "ok" }
      it { expect { entity.user = "user" }.to change(entity, :updated_at) }
    end
  end

  context "when using writers inside hooks" do
    let(:klass) do
      Class.new do
        include AccessorHooks

        attr_accessor :name, :full_name, :status

        before_change :clear_full_name, on: :name
        after_change :update_name, on: :status

        private

        def clear_full_name
          @full_name = ""
        end

        def update_name
          self.name = "new name"
        end
      end
    end

    let(:entity) { klass.new }

    it {
      expect(entity.name).to be_nil
      expect { entity.name = "Ivan" }.to change(entity, :full_name).to be_empty
      entity.full_name = "full name"
      expect { entity.status = "ok" }.to change(entity, :name).to eq("new name")
      expect(entity.full_name).to be_empty
    }
  end

  context "when using custom writer" do
    let(:klass) do
      Class.new do
        include AccessorHooks

        attr_reader :name, :full_name, :status

        def name=(value)
          @name = value
          @status = "ok"
        end

        before_change :start_update_full_name, on: :name
        after_change :update_full_name, on: :name

        private

        def start_update_full_name
          @full_name = "full"
        end

        def update_full_name
          @full_name += "_name"
        end
      end
    end

    let(:entity) { klass.new }

    it { expect { entity.name = "Ivan" }.to change(entity, :full_name).to eq("full_name") }
    it { expect { entity.name = "Ivan" }.to change(entity, :status).to eq("ok") }
    it { expect { entity.name = "Ivan" }.to change(entity, :name).to eq("Ivan") }
  end
end
