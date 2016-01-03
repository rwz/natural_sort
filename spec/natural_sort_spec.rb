require "spec_helper"

describe NaturalSort do
  it "has a version number" do
    expect(NaturalSort::VERSION).not_to be_nil
  end

  def assert_sorted(input, expected)
    expect(described_class.sort(input)).to eq(expected)
  end

  describe "sorting" do
    specify "basic" do
      input    = %w[a10 a a20 a1b a1a a2 a0 a1]
      expected = %w[a a0 a1 a1a a1b a2 a10 a20]

      assert_sorted input, expected
    end

    specify "multiple segments" do
      input    = %w[x2-g8 x8-y8 x2-y7 x2-y08]
      expected = %w[x2-g8 x2-y7 x2-y08 x8-y8]

      assert_sorted input, expected
    end

    specify "floats" do
      input    = %w[1.010 1.3 1.001 1.02 1.002 1.1]
      expected = %w[1.001 1.002 1.010 1.02 1.1 1.3]

      assert_sorted input, expected
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
      input =    %w[a b A B]
      expected = %w[A a B b]

      assert_sorted input, expected
    end

    specify "mixed segment types" do
      input =    %w[a 10 a10 10a a10a a10.a a10.A 10.20a 10.20]
      expected = %w[10 10a 10.20 10.20a a a10 a10.A a10.a a10a]

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

    specify "spaces in the middle" do
      input = [
        "a 2",
        "a1",
        "a 3",
        "a2"
      ]

      expected = [
        "a 2",
        "a 3",
        "a1",
        "a2"
      ]

      assert_sorted input, expected
    end
  end

  describe "api" do
    let(:input)    { %w[a10 a a20 a1b a1a a2 a0 a1] }
    let(:expected) { %w[a a0 a1 a1a a1b a2 a10 a20] }

    specify "class method" do
      expect(NaturalSort.sort(input)).to eq(expected)
    end

    specify "module as proc" do
      expect(input.sort(&NaturalSort)).to eq(expected)
    end

    specify "kernel method" do
      sorted = input.sort_by { |e| NaturalSort(e) }
      expect(sorted).to eq(expected)
    end
  end
end
