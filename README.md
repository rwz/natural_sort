# Natural Sort

[![Build Status](https://api.travis-ci.org/rwz/natural_sort.svg?branch=master)][travis]
[![Gem Version](http://img.shields.io/gem/v/natural_sort.svg)][gem]
[![Code Climate](http://img.shields.io/codeclimate/github/rwz/natural_sort.svg)][codeclimate]

[travis]: https://travis-ci.org/rwz/natural_sort
[gem]: https://rubygems.org/gems/natural_sort
[codeclimate]: https://codeclimate.com/github/rwz/natural_sort

Natual sorting implementation in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "natural_sort"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install natural_sort

## Usage

```ruby
require "natual_sort"

list = ["a10", "a", "a20", "a1b", "a1a", "a2", "a0", "a1"]
list.sort(&NaturalSort) # => ["a", "a0", "a1", "a1a", "a1b", "a2", "a10", "a20"]
```

```ruby
UbuntuRelease = Struct.new(:number, :name)

ubuntu_releases = [
  UbuntuRelease.new("9.04", "Jaunty Jackalope"),
  UbuntuRelease.new("10.10", "Maverick Meerkat"),
  UbuntuRelease.new("8.10", "Intrepid Ibex"),
  UbuntuRelease.new("10.04.4", "Lucid Lynx"),
  UbuntuRelease.new("9.10", "Karmic Koala"),
]

ubuntu_releases.sort_by { |v| NaturalSort(v.number) }
# => [
#   UbuntuRelease.new("8.10", "Intrepid Ibex"),
#   UbuntuRelease.new("9.04", "Jaunty Jackalope"),
#   UbuntuRelease.new("9.10", "Karmic Koala"),
#   UbuntuRelease.new("10.04.4", "Lucid Lynx"),
#   UbuntuRelease.new("10.10", "Maverick Meerkat")
# ]
```

## Refinements

If you're running ruby 2.1 or newer, you can use refinements.

```ruby
require "natural_sort/refinments"

class MyClass
  using NatualSort

  list.natural_sort                        # => ["a", "a0", "a1", "a1a"...
  ubuntu_releases.natual_sort_by(&:number) # => [ UbuntuRelease.new("8.10"...
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/rwz/natural_sort.


## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

