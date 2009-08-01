require "test/unit"
require "phuby"

class TestPhuby < Test::Unit::TestCase
  def test_runtime
    rt = Phuby::Runtime.new
    rt.start
    rt.eval("$hi = 'Hello World';")
    rt.eval("echo $hi;")
  end
end
