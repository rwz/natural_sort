require "natural_sort/version"

module NaturalSort
  module_function

  autoload :Segment,         "natural_sort/segment"
  autoload :SegmentedString, "natural_sort/segmented_string"

  def to_proc
    lambda(&method(:compare))
  end

  def sort(input)
    input.sort(&self)
  end

  def compare(a, b)
    SegmentedString.new(a) <=> SegmentedString.new(b)
  end
end

def NaturalSort(input)
  NaturalSort::SegmentedString.new(input)
end
