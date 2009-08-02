Process.setrlimit(Process::RLIMIT_CORE, Process::RLIM_INFINITY) unless RUBY_PLATFORM =~ /(java|mswin|mingw)/i

require 'test/unit'
require 'phuby'

module Phuby
  class TestCase < Test::Unit::TestCase
    ASSETS_DIR      = File.join(File.dirname(__FILE__), 'assets')

    unless RUBY_VERSION >= '1.9'
      undef :default_test
    end

    def setup
      warn "#{name}" if ENV['TESTOPTS'] == '-v'
    end
  end
end
