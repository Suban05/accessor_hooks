# AccessorHooks

`AccessorHooks` is a Ruby module that allows you to define hooks (`before_change` and `after_change`) on attribute writers. These hooks can be used to execute custom logic when an attribute is modified.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'accessor_hooks'
```

And then execute:

```sh
bundle install
```

Or install it manually:

```sh
gem install accessor_hooks
```

## Usage

Include `AccessorHooks` in your class and define hooks using `before_change` and `after_change`.

### Basic Example

```ruby
class User
  include AccessorHooks
  
  attr_reader :full_name
  attr_accessor :first_name, :last_name

  after_change :update_full_name, on: %i[first_name last_name]

  private

  def update_full_name
    @full_name = [first_name, last_name].join(" ").strip
  end
end

user = User.new
user.first_name = "John"
puts user.full_name # "John"

user.last_name = "Doe"
puts user.full_name # "John Doe"
```

### Using `before_change`

`before_change` hooks run before the attribute value is updated.

```ruby
class Document
  include AccessorHooks
  
  attr_reader :name
  attr_accessor :title

  before_change :clear_name, on: :title

  private

  def clear_name
    @name = ""
  end
end

doc = Document.new
doc.title = "New Title"
puts doc.name # ""
```

### Passing the New Attribute Value to the Hook

The new value of the attribute can be passed to the hook method.

```ruby
class FileEntity
  include AccessorHooks
  
  attr_reader :file_name
  attr_accessor :name

  after_change :update_file_name, on: :name

  private

  def update_file_name(name)
    @file_name = "#{name}.pdf"
  end
end

file = FileEntity.new
file.name = "document"
puts file.file_name # "document.pdf"
```

### Combining `before_change` and `after_change`

```ruby
class Record
  include AccessorHooks
  
  attr_reader :ids
  attr_accessor :id

  before_change :validate_id, on: :id
  after_change :store_id, on: :id

  def initialize
    @ids = []
  end

  private

  def validate_id(value)
    raise StandardError, "ID cannot be negative" if value < 0
  end

  def store_id
    @ids << @id
  end
end

record = Record.new
record.id = 1
puts record.ids.inspect # [1]

begin
  record.id = -1 # Raises StandardError
rescue StandardError => e
  puts e.message
end
```

## Running Tests

Run the test suite using RSpec:

```sh
bundle exec rspec
```

## License

This project is licensed under the MIT License.

