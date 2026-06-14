# frozen_string_literal: true

require "natural_sort"
require "set"

module NaturalSort
  [Array, Hash, Set].each do |klass|
    refine klass do
      def natural_sort
        to_a.sort(&NaturalSort)
      end

      def natural_sort_by
        to_a.sort_by do |element|
          NaturalSort::SegmentedString.new(yield(element))
        end
      end
    end
  end
end
