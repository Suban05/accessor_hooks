# frozen_string_literal: true

require_relative "lib/accessor_hooks/version"

Gem::Specification.new do |spec|
  spec.name = "accessor_hooks"
  spec.version = AccessorHooks::VERSION
  spec.authors = ["Anatoly Busygin"]
  spec.email = ["anatolyb94@gmail.com"]

  spec.summary = "Accessor hooks for Ruby attributes"
  spec.description = "Provides before and after hooks for attribute changes in Ruby " \
                     "classes, allowing easy execution of custom logic when " \
                     "attributes are modified."
  spec.homepage = "https://github.com/Suban05/accessor_hooks"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Suban05/accessor_hooks"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
