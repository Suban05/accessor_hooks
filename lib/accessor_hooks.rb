# frozen_string_literal: true

require_relative "accessor_hooks/version"

module AccessorHooks
  def self.included(base)
    base.extend ClassMethods
    base.instance_variable_set(:@event_hooks, {})
  end

  module ClassMethods
    def before_change(hook, on:)
      extend_writers(hook, :before_change, on)
    end

    def after_change(hook, on:)
      extend_writers(hook, :after_change, on)
    end

    def event_hooks
      @event_hooks
    end

    private

    def extend_writers(hook, event, attributes)
      Array(attributes).each do |attr|
        @event_hooks[attr] ||= {}
        if @event_hooks[attr].empty?
          save_original_writer(attr)
          extend_writer(attr)
        end
        @event_hooks[attr][event] = hook
      end
    end

    def extend_writer(attr)
      writer = writer_name(attr)
      define_method(:"#{attr}=") do |value|
        run_hook(attr, :before_change, value)
        send(writer, value)
        run_hook(attr, :after_change, value)
      end
    end

    def save_original_writer(attr)
      writer = writer_name(attr)
      alias_method writer, :"#{attr}="
      private writer
    end

    def writer_name(attr)
      :"set_#{attr}"
    end
  end

  def run_hook(attr, event, value)
    hook = self.class.event_hooks.dig(attr, event)
    return unless hook && respond_to?(hook, true)

    args = method(hook).arity == 1 ? [value] : []
    send(hook, *args)
  end

  private :run_hook
end
