#!/usr/bin/env ruby
# frozen_string_literal: true

# Regenerates spec/fixtures/strnatcmp_pairs.txt from Martin Pool's reference
# strnatcmp (vendored under script/vendor/, pinned to sourcefrog/natsort@cdd8df9).
#
# The input pairs below are the source of truth; this script computes the sign of
# strnatcmp(a, b) for each so the conformance spec can assert NaturalSort.compare
# reproduces the reference. To add a case, add a pair and rerun — never hand-edit
# the signs. Needs a C compiler (cc).
#
#   ruby script/regen_strnatcmp_fixture.rb

require "tmpdir"
require "open3"

VENDOR  = File.expand_path("vendor", __dir__)
FIXTURE = File.expand_path("../spec/fixtures/strnatcmp_pairs.txt", __dir__)
PINNED  = "sourcefrog/natsort@cdd8df9"

# Input pairs grouped by theme. ASCII only — the reference's non-ASCII byte
# ordering is signed-char- and platform-dependent, whereas NaturalSort uses
# unsigned byte order, so non-ASCII conformance is meaningless here. NaturalSort's
# own non-ASCII contract is pinned by the "malformed and non-ASCII input" specs.
GROUPS = [
  ["core ordering", [
    ["a2", "a10"], ["a10", "a2"], ["2", "10"], ["10", "9"],
    ["file9", "file10"], ["file10", "file9"]
  ]],
  ["leading-zero runs compare as text", [
    ["01333", "0400"], ["0400", "0401"], ["08", "1"], ["09", "1"],
    ["007", "7"], ["05", "5"], ["010", "10"]
  ]],
  ["fraction- and version-like decimals", [
    ["1.002", "1.02"], ["1.1", "1.02"], ["1.5", "1.50"],
    ["1.05", "1.5"], ["1.010", "1.02"]
  ]],
  ["arbitrarily large integers", [
    ["123456789012345678901234567890", "123456789012345678901234567897"],
    ["100000000000000000001", "100000000000000000000"]
  ]],
  ["a leading minus is text, not a sign", [
    ["-2", "-10"], ["-10", "-2"]
  ]],
  ["whitespace is insignificant but still splits digit runs", [
    ["a b", "ab"], ["1 0", "10"], [" a1", "a1"], ["a1 ", "a1"],
    ["a  b", "a b"], ["a 2", "a2"], ["1 2", "12"]
  ]],
  ["non-digits compare by byte value (case-sensitive)", [
    ["A", "a"], ["Z", "a"], ["B", "a"], ["a", "B"],
    ["Apple", "apple"], ["banana", "Banana"]
  ]],
  ["mixed digit / non-digit segments", [
    ["a10a", "a10"], ["a10", "a10a"], ["10a", "10"],
    ["a10.A", "a10.a"], ["10.20a", "10.20"]
  ]],
  ["prefixes and equality", [
    ["a", "a0"], ["a", "a1"], ["a1", "a1a"], ["a2", "a2"],
    ["1.0", "1.0"], ["v1.0", "v1.0"], ["v1.9", "v1.10"], ["v1.10", "v1.9"],
    ["1.2.3.2", "1.2.3.10"]
  ]],
  ["empty strings", [
    ["", ""], ["", "a"], ["", "0"], ["a", ""], ["0", ""]
  ]],
  ["a lone zero and zero-only runs", [
    ["0", "0"], ["0", "00"], ["00", "0"], ["0", "1"], ["00", "1"]
  ]],
  ["a leading plus is text, like minus", [
    ["+1", "1"], ["+1", "+2"], ["+2", "+10"]
  ]],
  ["tabs are whitespace, like spaces", [
    ["a\tb", "a b"], ["a\tb", "ab"], ["1\t2", "12"]
  ]],
  # Consecutive pairs that fix the total order x2-g8 < x2-y08 < x2-y7 < x8-y8.
  # The y08-vs-y7 step was once called ambiguous; it is reference-defined.
  ["multi-segment alphanumerics", [
    ["x2-g8", "x2-y08"], ["x2-y08", "x2-y7"], ["x2-y7", "x8-y8"]
  ]]
].freeze

def assert_ascii(groups)
  groups.each do |_title, pairs|
    pairs.flatten.each do |s|
      next if s.ascii_only?
      abort "non-ASCII input #{s.inspect} — this fixture is ASCII-only (see the header)"
    end
  end
end

def build_oracle(dir)
  bin = File.join(dir, "strnatcmp_ref")
  sources = ["strnatcmp.c", "driver.c"].map { |f| File.join(VENDOR, f) }
  out, status = Open3.capture2e("cc", "-O2", "-I", VENDOR, "-o", bin, *sources)
  abort "compile failed:\n#{out}" unless status.success?
  bin
end

def signs_for(bin, pairs)
  input = pairs.flat_map { |a, b| [a, b] }.map { |s| "#{s}\0" }.join.b
  out, status = Open3.capture2(bin, stdin_data: input)
  abort "oracle run failed" unless status.success?
  signs = out.split("\n").map(&:to_i)
  abort "sign count mismatch: #{signs.length} != #{pairs.length}" unless signs.length == pairs.length
  signs
end

HEADER = <<~TXT.chomp
  # strnatcmp conformance fixture — generated; do not edit by hand.
  #
  # TAB-separated: <a>\\t<b>\\t<sign>. <a>/<b> are Ruby String#dump literals (read
  # them back with String#undump); <sign> is the sign of strnatcmp(a, b): -1/0/1.
  #
  # Signs come from Martin Pool's reference strnatcmp (zlib-licensed), vendored at
  # script/vendor/ pinned to #{PINNED}. NaturalSort.compare(a, b) must reproduce
  # every sign.
  #
  # ASCII only: the reference's non-ASCII byte ordering is signed-char- and
  # platform-dependent, while NaturalSort uses unsigned byte order. Non-ASCII
  # behavior is pinned separately in the "malformed and non-ASCII input" specs.
  #
  # Regenerate (needs a C compiler):  ruby script/regen_strnatcmp_fixture.rb
TXT

assert_ascii(GROUPS)

body = Dir.mktmpdir do |dir|
  bin = build_oracle(dir)
  GROUPS.map do |title, pairs|
    signs = signs_for(bin, pairs)
    rows = pairs.each_with_index.map { |(a, b), i| "#{a.dump}\t#{b.dump}\t#{signs[i]}" }
    (["# --- #{title} ---"] + rows).join("\n")
  end.join("\n\n")
end

File.write(FIXTURE, "#{HEADER}\n\n#{body}\n")
puts "Wrote #{FIXTURE} (#{GROUPS.sum { |_t, p| p.length }} pairs)"
