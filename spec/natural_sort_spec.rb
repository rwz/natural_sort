# frozen_string_literal: true

require "spec_helper"
require "natural_sort/kernel"

describe NaturalSort do
  it "has a SemVer version number" do
    expect(NaturalSort::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end

  def assert_sorted(input, expected)
    expect(described_class.sort(input)).to eq(expected)
  end

  describe "sorting" do
    specify "basic" do
      input = %w[
        a10
        a
        a20
        a1b
        a1a
        a2
        a0
        a1
      ]

      expected = %w[
        a
        a0
        a1
        a1a
        a1b
        a2
        a10
        a20
      ]

      assert_sorted input, expected
    end

    specify "multiple numeric segments" do
      input = %w[
        1.2.3.2
        1.2.3.10
        1.2.3.1
      ]

      expected = %w[
        1.2.3.1
        1.2.3.2
        1.2.3.10
      ]

      assert_sorted input, expected
    end

    specify "floats" do
      input = %w[
        1.010
        1.3
        1.001
        1.02
        1.002
        1.1
      ]

      expected = %w[
        1.001
        1.002
        1.010
        1.02
        1.1
        1.3
      ]

      assert_sorted input, expected
    end

    specify "leading-zero numbers compare as text, not by value" do
      # "01333" sorts before "0400" and "0401": leading-zero runs compare by
      # byte value, so '1' < '4' wins even though 1333 > 400.
      assert_sorted %w[0400 01333 0401], %w[01333 0400 0401]
    end

    specify "bignums" do
      input = %w[
        123456789012345678901234567895
        123456789012345678901234567897
        123456789012345678901234567890
      ]

      expected = %w[
        123456789012345678901234567890
        123456789012345678901234567895
        123456789012345678901234567897
      ]

      assert_sorted input, expected
    end

    specify "very long floats" do
      input = %w[
        1.23456789012345678901234567895
        1.23456789012345678901234567897
        1.23456789012345678901234567890
      ]

      expected = %w[
        1.23456789012345678901234567890
        1.23456789012345678901234567895
        1.23456789012345678901234567897
      ]

      assert_sorted input, expected
    end

    specify "mixed case" do
      input = %w[
        a
        b
        A
        B
      ]

      # Non-digits compare by byte value, so every uppercase letter sorts
      # before every lowercase one (matches strnatcmp).
      expected = %w[
        A
        B
        a
        b
      ]

      assert_sorted input, expected
    end

    specify "mixed segment types" do
      input = %w[
        a
        10
        a10
        10a
        a10a
        a10.a
        a10.A
        10.20a
        10.20
      ]

      expected = %w[
        10
        10.20
        10.20a
        10a
        a
        a10
        a10.A
        a10.a
        a10a
      ]

      assert_sorted input, expected
    end

    specify "leading or trailing spaces" do
      input = [
        " a10",
        "a100",
        "a20 ",
        "a200",
        " a1 "
      ]

      expected = [
        " a1 ",
        " a10",
        "a20 ",
        "a100",
        "a200"
      ]

      assert_sorted input, expected
    end

    specify "whitespace is insignificant (matches strnatcmp)" do
      # Whitespace is skipped, so "a 2" and "a2" compare equal...
      expect(NaturalSort.compare("a 2", "a2")).to eq(0)
      expect(NaturalSort.compare(" a1 ", "a1")).to eq(0)
      expect(NaturalSort.compare("a  b", "a b")).to eq(0)

      # ...but it still separates adjacent digit runs, so "1 2" is [1, 2],
      # which sorts before "12".
      expect(NaturalSort.compare("1 2", "12")).to eq(-1)
    end
  end

  describe "api" do
    let(:input)    { %w[a10 a a20 a1b a1a a2 a0 a1] }
    let(:expected) { %w[a a0 a1 a1a a1b a2 a10 a20] }

    specify "class method" do
      expect(NaturalSort.sort(input)).to eq(expected)
    end

    specify "bang class method" do
      result = NaturalSort.sort!(input)
      expect(result).to equal(input)
      expect(input).to eq(expected)
    end

    specify "sort! rejects enumerables without #sort_by!" do
      expect { NaturalSort.sort!(Set["a10", "a2"]) }.to raise_error(ArgumentError, /sort!/)
    end

    specify "compare returns -1, 0, or 1" do
      expect(NaturalSort.compare("a2", "a10")).to eq(-1)
      expect(NaturalSort.compare("a10", "a2")).to eq(1)
      expect(NaturalSort.compare("a2", "a2")).to eq(0)
    end

    specify "module as proc" do
      expect(input.sort(&NaturalSort)).to eq(expected)
    end

    specify "kernel method" do
      sorted = input.sort_by { |e| NaturalSort(e) }
      expect(sorted).to eq(expected)
    end

    specify "to_proc returns a two-argument comparator" do
      expect(NaturalSort.to_proc.call("a2", "a10")).to eq(-1)
    end

    specify "key returns a comparable Key" do
      key = NaturalSort.key("a10")
      expect(key).to be_a(NaturalSort::Key)
      expect(key).to be < NaturalSort.key("a20")
    end
  end

  describe "value object" do
    it "is frozen and keeps its token list internal" do
      key = NaturalSort::Key.new("a10")
      expect(key).to be_frozen
      expect(key).not_to respond_to(:segments)
      expect(key).not_to respond_to(:input)
    end

    it "snapshots its input rather than aliasing a mutable string" do
      str = +"a10"
      key = NaturalSort::Key.new(str)
      str << "0"
      expect(key.to_s).to eq("a10")
    end
  end

  describe "comparison contract" do
    it "returns nil when compared with a non-Key" do
      expect(NaturalSort::Key.new("a") <=> "a").to be_nil
    end

    it "is unequal to other types instead of raising" do
      expect(NaturalSort::Key.new("9.04") == 5).to be(false)
    end

    it "three-way compares two wrapped strings" do
      smaller = NaturalSort::Key.new("a2")
      larger  = NaturalSort::Key.new("a10")
      expect(smaller <=> larger).to eq(-1)
    end
  end

  describe "equality and hashing" do
    it "treats equal keys as interchangeable in Hashes, Sets, and uniq" do
      a = NaturalSort::Key.new("a10")
      b = NaturalSort::Key.new("a10")
      expect(a).to eql(b)
      expect(a.hash).to eq(b.hash)
      expect([a, b].uniq.size).to eq(1)
      expect(Set[a, b].size).to eq(1)
    end

    it "is eql? to a whitespace-equivalent key, consistent with <=> == 0" do
      spaced = NaturalSort::Key.new("a 10")
      tight  = NaturalSort::Key.new("a10")
      expect(spaced <=> tight).to eq(0)
      expect(spaced).to eql(tight)
      expect(spaced.hash).to eq(tight.hash)
    end

    it "is not eql? to a non-Key" do
      expect(NaturalSort::Key.new("a10").eql?("a10")).to be(false)
    end
  end

  describe "edge cases" do
    it "returns an empty array unchanged" do
      expect(NaturalSort.sort([])).to eq([])
    end

    it "returns a single-element array unchanged" do
      expect(NaturalSort.sort(["only"])).to eq(["only"])
    end

    it "leaves an already-sorted array in order" do
      sorted = %w[a a1 a2 a10]
      expect(NaturalSort.sort(sorted)).to eq(sorted)
    end

    it "keeps equal keys together" do
      expect(NaturalSort.sort(%w[a a A])).to eq(%w[A a a])
    end

    it "sorts a frozen array but raises FrozenError on sort!" do
      frozen = %w[a10 a2 a1].freeze
      expect(NaturalSort.sort(frozen)).to eq(%w[a1 a2 a10])
      expect { NaturalSort.sort!(frozen) }.to raise_error(FrozenError)
    end
  end

  describe "malformed and non-ASCII input" do
    it "tokenizes invalid byte sequences by byte instead of raising" do
      # Latin-1 "é" (0xE9) mislabeled as UTF-8 — an invalid UTF-8 sequence.
      mojibake = "caf\xe9".dup.force_encoding("UTF-8")
      expect { NaturalSort.key(mojibake) }.not_to raise_error
      expect(NaturalSort.sort([mojibake, "cafe"])).to eq(["cafe", mojibake])
    end

    it "handles ASCII-incompatible encodings without raising" do
      expect { NaturalSort.key("abc123".encode("UTF-16LE")) }.not_to raise_error
    end

    it "orders valid UTF-8 by byte value (which equals codepoint order)" do
      # "é" is 0xC3 0xA9; its lead byte exceeds every ASCII byte, so it sorts
      # after "ay"/"az".
      assert_sorted ["az", "ay", "aé"], ["ay", "az", "aé"]
    end
  end

  describe "strnatcmp conformance" do
    # Pinned to Martin Pool's strnatcmp (https://github.com/sourcefrog/natsort),
    # the same algorithm PHP's strnatcmp implements. Each row is
    # dumped_a<TAB>dumped_b<TAB>sign, where the two strings are String#dump
    # literals; NaturalSort must reproduce every sign. Regenerate the fixture with
    # script/regen_strnatcmp_fixture.rb (see its header).
    fixture = File.readlines(File.expand_path("fixtures/strnatcmp_pairs.txt", __dir__), chomp: true)
    fixture.reject! { |line| line.empty? || line.start_with?("#") }

    fixture.each do |line|
      dumped_a, dumped_b, sign = line.split("\t")
      a = dumped_a.undump
      b = dumped_b.undump
      it "compare(#{a.inspect}, #{b.inspect}) == #{sign}" do
        expect(NaturalSort.compare(a, b) <=> 0).to eq(sign.to_i)
      end
    end
  end
end
