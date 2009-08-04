require 'helper'

class TestHeaderSent < Phuby::TestCase
  def test_headers_sent
    header = Class.new(Phuby::Events) {
      attr_accessor :response_code

      def send_headers response_code
        @response_code = response_code
      end
    }.new

    @rt = Phuby::Runtime.instance

    @rt.start

    @rt.events = header

    @rt.eval 'header("foo: bar", true, 500);'

    @rt.stop

    assert_equal 500, header.response_code
  end
end
