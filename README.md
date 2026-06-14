# Natural Sort

[![CI](https://github.com/rwz/natural_sort/actions/workflows/ci.yml/badge.svg)][ci]
[![Gem Version](https://img.shields.io/gem/v/natural_sort.svg)][gem]

[ci]: https://github.com/rwz/natural_sort/actions/workflows/ci.yml
[gem]: https://rubygems.org/gems/natural_sort

Natural-sort ordering for Ruby — sort strings the way people read them, so
`"a2"` comes before `"a10"` instead of after it.

```ruby
%w[a1 a10 a2].sort               # => ["a1", "a10", "a2"]   # lexical: a10 before a2
NaturalSort.sort(%w[a1 a10 a2])  # => ["a1", "a2", "a10"]   # natural
```

## Installation

Add it to your Gemfile:

```ruby
gem "natural_sort"
```

…then `bundle install`. Or grab it directly:

```
$ gem install natural_sort
```

Requires Ruby 3.3 or newer.

## Usage

`NaturalSort` is a comparator that plugs into Ruby's own sort methods — it
doesn't replace them.

```ruby
list = %w[a10 a a20 a1b a1a a2 a0 a1]

NaturalSort.sort(list)   # => ["a", "a0", "a1", "a1a", "a1b", "a2", "a10", "a20"]
NaturalSort.sort!(list)  # same, but sorts `list` in place and returns it
list.sort(&NaturalSort)  # NaturalSort works directly as the comparison block
```

To sort by a derived value, wrap it with the `NaturalSort()` helper:

```ruby
UbuntuRelease = Struct.new(:number, :name)

releases = [
  UbuntuRelease.new("9.04",    "Jaunty Jackalope"),
  UbuntuRelease.new("10.10",   "Maverick Meerkat"),
  UbuntuRelease.new("8.10",    "Intrepid Ibex"),
  UbuntuRelease.new("10.04.4", "Lucid Lynx"),
  UbuntuRelease.new("9.10",    "Karmic Koala"),
]

releases.sort_by { |release| NaturalSort(release.number) }
# => 8.10, 9.04, 9.10, 10.04.4, 10.10
```

## How it sorts

Each string is split into runs of digits and runs of non-digits, then compared
segment by segment:

- **Numbers compare numerically** — `"a2"` sorts before `"a10"`, and arbitrarily
  large integers compare exactly (no float rounding or overflow).
- **Letters compare case-insensitively**, with an uppercase letter ordered just
  before its lowercase twin: `"A"` before `"a"`, but both before `"b"`.
- **A number with a leading zero is treated as text**, so version- and
  decimal-like strings order the way you'd expect:

  ```ruby
  NaturalSort.sort(%w[1.1 1.02 1.002])  # => ["1.002", "1.02", "1.1"]
  ```

## Refinements

Prefer calling methods directly? Opt into `natural_sort` and `natural_sort_by`
on `Array`, `Hash`, and `Set`:

```ruby
require "natural_sort/refinements"

using NaturalSort

%w[a1 a10 a2].natural_sort           # => ["a1", "a2", "a10"]
releases.natural_sort_by(&:number)   # => sorted by version number
```

## Contributing

Bug reports and pull requests are welcome at
https://github.com/rwz/natural_sort.

## License

Available as open source under the terms of the [MIT License](LICENSE.txt).
