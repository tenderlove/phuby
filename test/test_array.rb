require 'helper'

class TestArray < Phuby::TestCase
  def test_move_to_runtime
    Phuby::Runtime.php do |rt|
      rt['foo'] = [1,2,3]
      assert_equal 1, rt['foo'][0]
      assert_equal 2, rt['foo'][1]
      assert_equal 3, rt['foo'][2]
    end
  end

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

  def test_index_numeric_get
    Phuby::Runtime.php do |rt|
      rt.eval('$foo = array(1,2,3,4,5);')
      list = []
      assert_equal 1, rt['foo'][0]
    end
  end

  def test_index_numeric_set
    Phuby::Runtime.php do |rt|
      rt.eval('$foo = array(1,2,3,4,5);')

      rt['foo'][0] = "hello"

      rt.eval('$bar = $foo[0];')

      assert_equal 'hello', rt['bar']
      assert_equal 'hello', rt['foo'][0]
    end
  end

  def test_each
    Phuby::Runtime.php do |rt|
      rt.eval('$foo = array(1,2,3,4,5);')

      array = rt['foo']

      other = []
      array.each do |thing|
        other << thing
      end
      assert_equal [1,2,3,4,5], other
    end
  end

  def test_to_a
    Phuby::Runtime.php do |rt|
      rt.eval('$foo = array(1,2,3,4,5);')

      array = rt['foo']

      assert_equal [1,2,3,4,5], array.to_a
    end
  end

  def test_get
    Phuby::Runtime.php do |rt|
      rt.eval('$_GET["foo"] = "bar";')
      #rt.eval('var_dump($_GET);')

      assert_equal 'bar', rt['_GET']['foo']
    end
  end

  def test_set
    Phuby::Runtime.php do |rt|
      rt['_GET']['foo'] = "bar"
      rt.eval('$foo = $_GET["foo"];')
      #rt.eval('var_dump($_GET);')

      assert_equal 'bar', rt['foo']
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
