# frozen_string_literal: true

require "spec_helper"
require "natural_sort/refinements"

using NaturalSort

describe "NaturalSort refinements" do
  describe "Array#natural_sort" do
    it "returns a naturally-ordered Array" do
      expect(%w[a10 a2 a1].natural_sort).to eq(%w[a1 a2 a10])
    end
  end

  describe "Set#natural_sort" do
    it "returns a naturally-ordered Array, not a Set" do
      result = Set["a10", "a2", "a1"].natural_sort
      expect(result).to eq(%w[a1 a2 a10])
      expect(result).to be_an(Array)
    end
  end

  describe "Hash#natural_sort" do
    it "returns [key, value] pairs in natural key order" do
      hash = { "a10" => 1, "a2" => 2, "a1" => 3 }
      expect(hash.natural_sort).to eq([["a1", 3], ["a2", 2], ["a10", 1]])
    end

    it "orders by key alone — values never influence the order" do
      # "a1" and "a 1" compare equal (whitespace is insignificant), so only the
      # key may decide their order. Flipping the values must not flip the order.
      one = { "a1" => 2, "a 1" => 1 }
      two = { "a1" => 1, "a 1" => 2 }
      expect(one.natural_sort.map(&:first)).to eq(two.natural_sort.map(&:first))
    end
  end

  describe "#natural_sort_by" do
    it "sorts by the value derived in the block" do
      release = Struct.new(:number)
      releases = [release.new("9.10"), release.new("9.04"), release.new("10.04")]
      expect(releases.natural_sort_by(&:number).map(&:number)).to eq(%w[9.04 9.10 10.04])
    end
  end
end
