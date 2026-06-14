# frozen_string_literal: true

require "natural_sort"

module NaturalSort
  [Array, Hash, Set].each do |klass|
    refine klass do
      def natural_sort
        # For a Hash, +to_a+ yields [key, value] pairs; key on the key alone so
        # the value never sways ordering. For Array/Set the element is taken whole.
        to_a.sort_by { |element, _| NaturalSort.key(element) }
      end

      def natural_sort_by
        to_a.sort_by { |element| NaturalSort.key(yield(element)) }
      end
    end
  end
end
