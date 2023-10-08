# frozen_string_literal: true

require_relative "lib/asciidoctor-server/version"

Gem::Specification.new do |spec|
  spec.name = "asciidoctor-server"
  spec.version = Asciidoctor::Server::VERSION
  spec.authors = ["hybras"]
  spec.email = ["24651269+hybras@users.noreply.github.com"]

  spec.summary = "Run asciidoctor as a server"
  spec.description = "Run asciidoctor as a server and avoid the cost of spawning multiple processes"
  spec.homepage = "https://github.com/hybras/asciidoctor-server"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"
  spec.extra_rdoc_files = ["../Readme.adoc"]

  spec.metadata["allowed_push_host"] = "https://rubygems.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "asciidoctor", "~> 2.0"
  spec.add_dependency "grpc", "~> 1.0"
  spec.add_dependency "logging", "~> 1.0"
  spec.add_dependency "optparse", "~> 0.3.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
