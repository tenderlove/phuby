require 'singleton'

module Phuby
  class Runtime
    include Singleton

    def initialize
      @events = Events.new
    end

    def with_events event
      old = @events
      @events = event
      yield self
      @events = old
    end

    def eval string_or_io, filename = "nil"
      if string_or_io.respond_to? :read
        native_eval_io string_or_io, filename
      else
        native_eval string_or_io, filename
      end
    end
  end
end
