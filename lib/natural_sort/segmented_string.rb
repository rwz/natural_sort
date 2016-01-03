module NaturalSort
  class SegmentedString
    include Comparable

    TOKENIZER = /\d+(?:\.\d+)?|\D/
    private_constant :TOKENIZER

    attr_reader :input

    def initialize(input)
      @input = input.to_s
    end

    def segments
      @segments ||= tokens.map { |token| Segment.new(token) }
    end

    def <=>(other)
      raise ArgumentError unless SegmentedString === other

      other_segments = other.segments

      segments.each_with_index do |segment, index|
        other_segment = other_segments[index]
        return 1 if other_segment.nil?
        result = compare_segments(segment, other_segment)
        return result unless result.zero?
      end

      other_segments.length > segments.length ? -1 : 0
    end

    private

    def tokens
      @tokens ||= input.scan(TOKENIZER)
    end

    def compare_segments(segment, other)
      segment <=> other
    end
  end
end
