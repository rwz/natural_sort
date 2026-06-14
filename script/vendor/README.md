# Vendored reference

`strnatcmp.c` and `strnatcmp.h` are Martin Pool's natural-order string
comparison, copied verbatim from
[sourcefrog/natsort](https://github.com/sourcefrog/natsort) at commit
`cdd8df9602e727482ae5e051cff74b7ec7ffa07a`, under the zlib license (see the file
headers). They exist only to regenerate the conformance fixture via
`script/regen_strnatcmp_fixture.rb` and are **not** part of the published gem.

`driver.c` is natural_sort's own test harness, not part of the reference.
