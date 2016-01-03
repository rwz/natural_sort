require File.expand_path("../lib/natural_sort/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name         = "natural_sort"
  spec.version      = NaturalSort::VERSION
  spec.authors      = ["Pavel Pravosud"]
  spec.email        = ["pavel@pravosud.com"]
  spec.summary      = "Natural sorting support for Ruby"
  spec.homepage     = "https://github.com/rwz/natural_sort"
  spec.license      = "MIT"
  spec.files        = Dir["LICENSE.txt", "README.md", "lib/**/**"]
  spec.require_path = "lib"
end
