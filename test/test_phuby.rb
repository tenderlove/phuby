require "test/unit"
require "phuby"

class TestPhuby < Test::Unit::TestCase
  def setup
    @rt = Phuby::Runtime.new
    @rt.start
  end

  def teardown
    @rt.stop
  end

  def test_runtime
    @rt.eval("$hi = 'Hello World';")
    @rt.eval("echo $hi;")
  end
end
