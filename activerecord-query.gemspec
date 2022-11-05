# frozen_string_literal: true

require_relative "lib/active_record_query/version"

Gem::Specification.new do |spec|
  spec.name = "activerecord-query"
  spec.version = ActiveRecordQuery::VERSION
  spec.authors = ["marcos"]
  spec.email = ["marcosfelipesilva54@gmail.com"]
  spec.summary = "Small DSL for query build with Active Record."
  spec.description = "The DSL provides a nice and clean way to write a Model query better than model scopes."
  spec.homepage = "https://github.com/marcosfelipe/activerecord-query"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + '/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['README.md', 'LICENSE',
                   'CHANGELOG.md', 'lib/**/*.rb',
                   'lib/**/*.rake',
                   '*.gemspec', '.github/*.md',
                   'Gemfile', 'Rakefile']
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4.0", "< 8.0"
  spec.add_dependency "activesupport", ">= 4.0", "< 8.0"

  spec.add_development_dependency "bundler", '>= 1.3', '< 3.0'
  spec.add_development_dependency "rake", '>= 1.0', '< 14.0'
  spec.add_development_dependency "rspec",   "~> 3.0"
  spec.add_development_dependency "pry", '~> 0.14.0'
  spec.add_development_dependency "sqlite3", '~> 1.0'
  spec.add_development_dependency "simplecov", '~> 0.21.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
