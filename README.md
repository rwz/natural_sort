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

`sort(&NaturalSort)` works because the module is a *comparator*. To sort by a
*derived* value you want a *key* instead — `NaturalSort.key(x)`, or the
`NaturalSort()` helper — for `sort_by`, `min_by`, and friends:

```ruby
require "natural_sort/kernel"

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

`NaturalSort()` is a global helper — a `Kernel` method in the spirit of
`Integer()` or `Array()`. It lives in a separate file so that requiring the gem
(or its refinements) never adds a method to every object unless you explicitly
ask for it with `require "natural_sort/kernel"`. If you'd rather not add a
global method, `NaturalSort.key(value)` does the same thing:

```ruby
releases.sort_by { |release| NaturalSort.key(release.number) }
```

## How it sorts

`NaturalSort` is a faithful port of [Martin Pool's natural-order string
comparison][natsort] — the same algorithm PHP's `strnatcmp` uses. When an
ordering looks ambiguous, that implementation is the source of truth.

Each string is split into runs of digits and runs of non-digits, then compared
segment by segment:

- **Numbers compare numerically** — `"a2"` sorts before `"a10"`, and arbitrarily
  large integers compare exactly (no float rounding or overflow).
- **Everything else compares by byte value** (case-sensitive ASCII), so every
  uppercase letter sorts before every lowercase one.
- **A digit run with a leading zero is treated as text**, so fraction- and
  version-like strings order the way you'd expect:

  ```ruby
  NaturalSort.sort(%w[1.1 1.02 1.002])  # => ["1.002", "1.02", "1.1"]
  ```
- **Whitespace is skipped** — it never affects ordering on its own, though it
  still separates adjacent digit runs.

[natsort]: https://github.com/sourcefrog/natsort

## Surprising cases

Because this matches `strnatcmp` exactly, it inherits a few results that catch
people off guard — all consequences of the rules above:

```ruby
# A leading zero makes a number sort like a fraction, so "08" and "09" land
# BEFORE "1" — not where you'd put the eighth and ninth items.
NaturalSort.sort(%w[10 08 1 09 2])   # => ["08", "09", "1", "2", "10"]
NaturalSort.sort(%w[1.5 1.50 1.05])  # => ["1.05", "1.5", "1.50"]

# Among themselves, leading-zero numbers compare as text, so "01333" sorts
# BEFORE "0400" and "0401" — '1' beats '4' even though 1333 > 400.
NaturalSort.sort(%w[0400 01333 0401])  # => ["01333", "0400", "0401"]

# Whitespace is insignificant, so these compare equal...
NaturalSort.compare("a b", "ab")     # => 0
# ...but it still splits a number in two, so "1 0" is [1, 0], not 10:
NaturalSort.compare("1 0", "10")     # => -1

# Case-sensitive byte order: every uppercase letter sorts before every
# lowercase one (so "Z" sorts before "a").
NaturalSort.sort(%w[banana Apple apple Banana])
# => ["Apple", "Banana", "apple", "banana"]
```

Want case-insensitive ordering? Normalize your keys:

```ruby
%w[img10 IMG2 img1].sort_by { |s| NaturalSort.key(s.downcase) }
# => ["img1", "IMG2", "img10"]
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
