# frozen_string_literal: true

module NaturalSort
  # A precomputed, comparable sort key. Wrap a value with NaturalSort.key (or
  # the NaturalSort() helper) and use it as a sort_by key:
  #
  #   array.sort_by { |string| NaturalSort.key(string) }
  #
  # The string is split once, on construction: digit runs with no leading zero
  # become Integers (compared by value); everything else — text, and digit runs
  # with a leading zero — stays a String (compared by byte value). Whitespace is
  # skipped. This reproduces Martin Pool's strnatcmp ordering.
  class Key
    include Comparable

    TOKENIZER  = /\d+|\D/
    NUMERIC    = /\A[1-9]\d*\z/
    WHITESPACE = /\A\s+\z/
    private_constant :TOKENIZER, :NUMERIC, :WHITESPACE

    attr_reader :input, :segments

    def initialize(input)
      @input = input.to_s
      @segments = @input.scan(TOKENIZER).filter_map do |token|
        if token.match?(WHITESPACE)
          nil
        elsif NUMERIC.match?(token)
          Integer(token)
        else
          token
        end
      end
    end

    def to_s
      @input
    end

    # Three-way comparison. Numeric segments (Integers) compare by value when
    # paired with another numeric segment; in every other pairing both sides
    # compare by byte value. A non-zero-leading integer's #to_s is its original
    # digits, so the cross-type byte comparison stays exact.
    #
    # @return [Integer, nil] -1, 0, or 1, or nil when +other+ is not a Key
    def <=>(other)
      return nil unless other.is_a?(Key)

      mine = segments
      theirs = other.segments
      index = 0

      while index < mine.length
        right = theirs[index]
        return 1 if right.nil?

        left = mine[index]
        result =
          if left.is_a?(Integer)
            right.is_a?(Integer) ? left <=> right : left.to_s <=> right
          else
            right.is_a?(Integer) ? left <=> right.to_s : left <=> right
          end
        return result unless result.zero?

        index += 1
      end

      theirs.length > mine.length ? -1 : 0
    end
  end
end
