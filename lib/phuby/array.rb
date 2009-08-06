module Phuby
  class Array
    def [] key
      get key
    end

    def []= key, value
      set key, value
    end
  end
end
