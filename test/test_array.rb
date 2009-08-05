require 'helper'

class TestArray < Phuby::TestCase
  def setup
    super
    @rt = Phuby::Runtime.instance
    @rt.start
  end

  def teardown
    super
    @rt.stop
  end

  def test_array_returns
    @rt.eval('$get_length = count($_GET);')
    assert_equal @rt['get_length'], @rt['_GET'].length

    10.times { |i|
      @rt.eval("$_GET['foo#{i}'] = 'bar'; $get_length = count($_GET);")
      assert_equal @rt['get_length'], @rt['_GET'].length
    }
  end
end
