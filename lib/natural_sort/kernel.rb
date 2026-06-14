# frozen_string_literal: true

require "natural_sort"

# Conversion-style helper (in the spirit of Integer()/Array()): wraps +input+
# in a SegmentedString suitable as a sort_by key. Opt-in — requiring this file
# defines it at the top level, so it lands on Kernel and becomes callable on
# every object.
def NaturalSort(input)
  NaturalSort::SegmentedString.new(input)
end
