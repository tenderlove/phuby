module Phuby
  class Runtime
    def eval string, filename = __FILE__
      native_eval string, filename
    end
  end
end
