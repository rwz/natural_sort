require "set"

module NaturalSort
  [Array, Hash, Set].each do |klass|
    refine klass do
      def natural_sort
        to_a.sort(&NaturalSort)
      end

      def natural_sort_by
        to_a.sort_by do |element|
          NaturalSort(yield(element))
        end
      end
    end
  end
end
