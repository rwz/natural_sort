# frozen_string_literal: true

require "natural_sort"

# Conversion-style helper (in the spirit of Integer()/Array()): wraps +input+
# in a NaturalSort comparison key for use as a sort_by key, e.g.
# +list.sort_by { |x| NaturalSort(x) }+. Opt-in — requiring this file defines
# it at the top level, so it lands on Kernel and is callable on every object.
#
# @param input [#to_s]
# @return [NaturalSort::Key]
def NaturalSort(input)
  NaturalSort.key(input)
end
