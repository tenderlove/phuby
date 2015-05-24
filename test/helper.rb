#Process.setrlimit(Process::RLIMIT_CORE, Process::RLIM_INFINITY) unless RUBY_PLATFORM =~ /(java|mswin|mingw)/i

require 'phuby'
require 'minitest/autorun'

module Phuby
  class TestCase < Minitest::Test
    ASSETS_DIR      = File.join(File.dirname(__FILE__), 'assets')
    HTDOCS_DIR      = File.join(File.dirname(__FILE__), 'assets', 'htdocs')

    unless RUBY_VERSION >= '1.9'
      undef :default_test
    end

    def setup
      warn "#{name}" if ENV['TESTOPTS'] == '-v'
    end
  end
end
