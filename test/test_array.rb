require 'helper'

class TestArray < Phuby::TestCase
  def test_array_length
    Phuby::Runtime.php do |rt|
      rt.eval('$get_length = count($_GET);')
      assert_equal rt['get_length'], rt['_GET'].length

      10.times { |i|
        rt.eval("$_GET['foo#{i}'] = 'bar'; $get_length = count($_GET);")
        assert_equal rt['get_length'], rt['_GET'].length
      }
    end
  end

  def test_get
    Phuby::Runtime.php do |rt|
      rt.eval('$_GET["foo"] = "bar";')
      #rt.eval('var_dump($_GET);')

      assert_equal 'bar', rt['_GET']['foo']
    end
  end

  def test_get_non_existent
    Phuby::Runtime.php do |rt|
      assert_nil rt['_GET']['foo']
    end
  end

  def test_key?
    Phuby::Runtime.php do |rt|
      rt.eval('$_GET["foo"] = "bar";')
      assert rt['_GET'].key? 'foo'
    end
  end
end
