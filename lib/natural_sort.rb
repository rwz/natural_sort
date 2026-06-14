# frozen_string_literal: true

require "natural_sort/version"

module NaturalSort
  module_function

  autoload :Segment,         "natural_sort/segment"
  autoload :SegmentedString, "natural_sort/segmented_string"

  # Comparator proc, so the module itself works as a sort block:
  # +list.sort(&NaturalSort)+.
  #
  # @return [Proc] a two-argument comparator returning -1, 0, or 1
  def to_proc
    lambda(&method(:compare))
  end

  # Natural-sorts +input+ into a new array.
  #
  # @param input [Enumerable] strings (or any +#to_s+-able values)
  # @return [Array] a new array in natural order
  def sort(input)
    input.sort_by { |element| SegmentedString.new(element) }
  end

  # Natural-sorts +input+ in place.
  #
  # @param input [Array]
  # @return [Array] +input+ itself, sorted
  def sort!(input)
    input.sort_by! { |element| SegmentedString.new(element) }
  end

  # Three-way natural-order comparison of two values (each coerced via +#to_s+).
  #
  # @param a [#to_s]
  # @param b [#to_s]
  # @return [Integer] -1, 0, or 1
  def compare(a, b)
    SegmentedString.new(a) <=> SegmentedString.new(b)
  end
end
