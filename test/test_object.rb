require 'helper'

class TestObject < Phuby::TestCase
  def test_method_call
    x = Class.new {
      attr_reader :called
      def initialize
        @called = false
      end

      def hello
        @called = true
      end
    }.new
    Phuby::Runtime.php do |rt|
      rt['x'] = x
      rt.eval('$x->hello();')
    end
    assert x.called
  end
end
