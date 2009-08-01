module Phuby
  class Runtime
    def eval string_or_io, filename = "nil"

      if string_or_io.respond_to? :read
        native_eval_io string_or_io, filename
      else
        native_eval string_or_io, filename
      end
    end
  end
end
