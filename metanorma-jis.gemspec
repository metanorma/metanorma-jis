# coding: utf-8

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "metanorma/jis/version"

Gem::Specification.new do |spec|
  spec.name          = "metanorma-jis"
  spec.version       = Metanorma::Jis::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "metanorma-jis lets you write JIS standards "\
                       "in AsciiDoc."
  spec.description   = <<~DESCRIPTION
    metanorma-jis lets you write JIS standards in AsciiDoc syntax.

    This gem is in active development.
  DESCRIPTION

  spec.homepage      = "https://github.com/metanorma/metanorma-jis"
  spec.license       = "BSD-2-Clause"

  spec.bindir        = "bin"
  spec.require_paths = ["lib"]
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|bin|.github)/}) \
    || f.match(%r{Rakefile|bin/rspec})
  end
  spec.test_files = `git ls-files -- {spec}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1.0")

  spec.add_dependency "japanese_calendar", "~> 0"
  spec.add_dependency "metanorma-iso", "~> 3.1.0"
  spec.add_dependency "pubid"

  spec.add_development_dependency "debug"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "iev", "~> 0.3.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rubocop", "~> 1"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "sassc-embedded", "~> 1"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "xml-c14n"
end
