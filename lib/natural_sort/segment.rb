module NaturalSort
  class Segment
    include Comparable

    # Segments that look like numbers, but start with 0 should be treated as
    # strings, so that we don't asumme that 1.020 is more than 1.1 cause 20 > 1
    NUMERIC = /\A[1-9]\d*\z/
    private_constant :NUMERIC

    attr_reader :input

    def initialize(input)
      @input = input.to_s
    end

    def to_s
      @input
    end

    def <=>(other)
      if numeric? && other.numeric?
        Rational(input) <=> Rational(other.to_s)
      else
        compare_chars(input, other.to_s)
      end
    end

    def numeric?
      NUMERIC === input
    end

    private

    def compare_chars(a, b)
      a == b.swapcase ? a <=> b : a.downcase <=> b.downcase
    end
  end
end
