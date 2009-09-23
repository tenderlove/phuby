require 'singleton'
require 'thread'

module Phuby
  class Runtime
    include Singleton

    attr_accessor :events

    def self.php &block
      instance.php(&block)
    end

    def initialize
      @events       = Events.new
      @mutex        = Mutex.new
      @proxy_map    = {}
    end

    def started?
      @mutex.locked?
    end

    def with_events event
      old = @events
      @events = event
      yield self
      @events = old
    end

    def eval string_or_io, filename = nil
      raise NotStartedError, "please start the runtime" unless @mutex.locked?

      if string_or_io.respond_to? :read
        native_eval_io string_or_io, filename || string_or_io.path
      else
        native_eval string_or_io, filename || __FILE__
      end
    end

    def php &block
      start
      block.call(self)
    ensure
      stop
    end

    def [] key
      raise NotStartedError, "please start the runtime" unless @mutex.locked?
      get key
    end

    def []= key, value
      raise NotStartedError, "please start the runtime" unless @mutex.locked?
      set key, value
    end

    class NotStartedError < RuntimeError; end
  end
end
