require 'helper'

class TestPhuby < Phuby::TestCase
  def setup
    super
    @rt = Phuby::Runtime.instance
    @rt.start
  end

  def teardown
    super
    @rt.stop
  end

  def test_eval
    @rt.eval("$hi = 'Hello World';")
  end

  def test_get_return_int
    @rt.eval("$hi = 2;")
    assert_equal 2, @rt['hi']
  end

  def test_get_return_nil
    @rt.eval("$hi = null;")
    assert_nil @rt['hi']
  end

  def test_get_return_float
    @rt.eval("$hi = 3.14159;")
    assert_equal 3.14159, @rt['hi']
  end

  def test_get_return_bool
    @rt.eval("$hi = true;")
    assert_equal true, @rt['hi']

    @rt.eval("$hi = false;")
    assert_equal false, @rt['hi']
  end

  def test_get_return_string
    @rt.eval("$hi = 'world';")
    assert_equal 'world', @rt['hi']
  end

  def test_set_int
    assert_equal 10, @rt['hi'] = 10
    @rt.eval('$hi += 2;')
    assert_equal 12, @rt['hi']
  end

  def test_set_bool
    assert_equal false, @rt['hi'] = false
    @rt.eval('$hi = !$hi;')
    assert_equal true, @rt['hi']
  end

  def test_set_string
    assert_equal "hello", @rt['hi'] = "hello"
    @rt.eval('$hi = $hi . " world";')
    assert_equal 'hello world', @rt['hi']
  end

  def test_set_float
    assert_equal 3.14159, @rt['hi'] = 3.14159
    @rt.eval('$hi += 1.0;')
    assert_equal 4.14159, @rt['hi']
  end

  def test_file_handle
    File.open(File.join(ASSETS_DIR, 'hello_world.php'), 'rb') { |fh|
      @rt.eval fh
    }
    assert_equal 'world', @rt['hi']
  end

  #def test_mysql
  #  @rt['dbhost'] = 'localhost'
  #  @rt['dbuser'] = 'root'
  #  @rt['dbpassword'] = nil
  #  @rt.eval('@mysql_connect($dbhost, $dbuser, $dbpassword, true);')
  #end
end
