# frozen_string_literal: true

require "natural_sort"

module NaturalSort
  [Array, Hash, Set].each do |klass|
    refine klass do
      def natural_sort
        to_a.sort_by { |element| NaturalSort.key(element) }
      end

      def natural_sort_by
        to_a.sort_by { |element| NaturalSort.key(yield(element)) }
      end
    end
  end
end
