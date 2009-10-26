require 'helper'

class TestObject < Phuby::TestCase
  class FunObject
    attr_reader :called, :values
    def initialize
      @called = false
      @values = []
    end

    def hello
      @called = true
    end

    def value x
      @values << x
    end
  end

  def test_stringio
    Phuby::Runtime.php do |rt|
      rt['x'] = StringIO.new('')
    end
  end

  def test_method_call
    x = FunObject.new
    Phuby::Runtime.php do |rt|
      rt['x'] = x
      rt.eval('$x->hello();')
    end
    assert x.called
  end

  def test_method_call_with_args
    x = FunObject.new
    Phuby::Runtime.php do |rt|
      rt['x'] = x
      rt.eval('$x->value("foo");')
      rt.eval('$x->value("bar");')
    end
    assert_equal %w{ foo bar }, x.values
  end
end
