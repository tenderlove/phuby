require 'helper'

class TestRuntime < Phuby::TestCase
  def test_start_stop
    rt = Phuby::Runtime.instance
    rt.start
    rt.stop
    rt.start
    rt.stop
  end

  def test_mutex_lock
    rt = Phuby::Runtime.instance
    rt.start

    assert_raises ThreadError do
      rt.start
    end

  ensure
    rt.stop
  end
end
