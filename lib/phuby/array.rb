module Phuby
  class Array
    def [] key
      get key
    end

    def []= key, value
      set key, value
    end

    def each &block
      0.upto(length - 1) do |i|
        block.call get(i)
      end
    end

    def to_a
      tmp = []
      each { |x| tmp << x }

      tmp
    end
  end
end
