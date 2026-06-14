# frozen_string_literal: true

require "natural_sort/version"

module NaturalSort
  module_function

  autoload :Key, "natural_sort/key"

  # Comparator proc, so the module itself works as a sort block:
  # +list.sort(&NaturalSort)+. Prefer +sort+ or +sort_by { NaturalSort.key(x) }+
  # when speed matters — those build one key per element instead of one per
  # comparison.
  #
  # @return [Proc] a two-argument comparator returning -1, 0, or 1
  def to_proc
    method(:compare).to_proc
  end

  # Natural-sorts +input+ into a new array. Not stable: elements whose
  # natural-order keys are equal may be reordered relative to each other.
  #
  # @param input [Enumerable] strings (or any +#to_s+-able values)
  # @return [Array] a new array in natural order
  def sort(input)
    input.sort_by { |element| Key.new(element) }
  end

  # Natural-sorts +input+ in place. Like {sort}, not stable for equal keys.
  #
  # @param input [Array] (or anything with +#sort_by!+)
  # @return [Array] +input+ itself, sorted
  # @raise [ArgumentError] when +input+ cannot be sorted in place
  def sort!(input)
    unless input.respond_to?(:sort_by!)
      raise ArgumentError, "sort! needs an Array (or anything with #sort_by!); use sort for other enumerables"
    end

    input.sort_by! { |element| Key.new(element) }
  end

  # Three-way natural-order comparison of two values (each coerced via +#to_s+).
  #
  # @param a [#to_s]
  # @param b [#to_s]
  # @return [Integer] -1, 0, or 1
  def compare(a, b)
    Key.new(a) <=> Key.new(b)
  end

  # The comparable sort key for +value+, for use as a +sort_by+ key.
  #
  # @param value [#to_s]
  # @return [NaturalSort::Key]
  def key(value)
    Key.new(value)
  end
end
