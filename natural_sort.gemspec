# frozen_string_literal: true

require File.expand_path("../lib/natural_sort/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name         = "natural_sort"
  spec.version      = NaturalSort::VERSION
  spec.authors      = ["Pavel Pravosud"]
  spec.email        = ["pavel@pravosud.com"]
  spec.summary      = "Natural sorting support for Ruby"
  spec.description  = <<~DESC
    Natural-sort ordering for Ruby: split strings into digit and non-digit
    runs and compare numerically, so "a2" sorts before "a10". Plugs into
    Ruby's own sort methods, with optional Array/Hash/Set refinements and an
    opt-in NaturalSort() helper.
  DESC
  spec.homepage     = "https://github.com/rwz/natural_sort"
  spec.license      = "MIT"
  spec.required_ruby_version = ">= 3.3"
  spec.metadata = {
    "homepage_uri"          => spec.homepage,
    "source_code_uri"       => "https://github.com/rwz/natural_sort/tree/v#{NaturalSort::VERSION}",
    "bug_tracker_uri"       => "https://github.com/rwz/natural_sort/issues",
    "changelog_uri"         => "https://github.com/rwz/natural_sort/blob/main/CHANGELOG.md",
    "documentation_uri"     => "https://rubydoc.info/gems/natural_sort",
    "rubygems_mfa_required" => "true",
  }
  spec.files        = Dir["LICENSE.txt", "README.md", "CHANGELOG.md", "lib/**/*.rb"]
  spec.require_path = "lib"
end
