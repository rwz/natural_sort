# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). The sort
order itself is part of the public API — a change to how strings are ordered is
a breaking change.

## [1.0.0] - 2026-06-14

First stable release.

Ordering is a faithful port of Martin Pool's natural-order string comparison
(the algorithm PHP's `strnatcmp` uses), so results are reference-defined.
Ordering may differ from the 0.x series — review your sort output before
upgrading, and pin with `~> 1.0`.

- Faithful `strnatcmp` ordering: leading-zero digit runs compare as text,
  whitespace is insignificant on its own, non-digit bytes compare by byte value
  (case-sensitive), and arbitrarily large integers compare exactly.
- Plugs into Ruby's own sort methods: `NaturalSort.sort`, `.sort!`, `.compare`,
  `.key`, and `&NaturalSort` as a comparison block.
- `NaturalSort::Key` is a frozen, immutable comparison key.
- Tolerates malformed or ASCII-incompatible encodings, sorting by byte value
  instead of raising.
- Opt-in extras kept out of the default require: the `NaturalSort()` Kernel
  helper (`require "natural_sort/kernel"`) and `Array`/`Hash`/`Set` refinements
  (`require "natural_sort/refinements"`).
- Requires Ruby 3.3 or newer.

## [0.3.0] - 2018-09-27

- Handle additional edge cases for multi-segment numbers.

## [0.2.0] - 2016-11-14

- Add `NaturalSort.sort!` and expand the usage examples.

## [0.1.0] - 2016-01-03

- Initial release.

[1.0.0]: https://github.com/rwz/natural_sort/compare/v0.3.0...v1.0.0
[0.3.0]: https://github.com/rwz/natural_sort/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/rwz/natural_sort/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/rwz/natural_sort/releases/tag/v0.1.0
