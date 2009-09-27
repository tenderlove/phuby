require 'helper'

class TestNil < Phuby::TestCase
  def test_nil_moves
    Phuby::Runtime.php do |rt|
      rt['foo'] = nil
      assert_nil rt['foo']
    end
  end
end
