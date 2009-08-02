require 'helper'

class TestHeaderHandler < Phuby::TestCase
  def setup
    super
    @rt = Phuby::Runtime.instance
    @rt.start
  end

  def teardown
    super
    @rt.stop
  end

  def test_capture_output
    quiet = Class.new(Phuby::Events) {
      attr_accessor :written

      def write string
        @written ||= []
        @written << string
      end
    }.new

    @rt.with_events(quiet) do |rt|
      rt.eval 'echo "hello world";'
    end

    assert_equal ['hello world'], quiet.written
  end

  def test_header_handler
    header = Class.new(Phuby::Events) {
      attr_accessor :headers

      def header header, op
        @headers ||= []
        @headers << [header, op]
      end
    }.new

    @rt.with_events(header) do |rt|
      rt.eval 'setcookie("name", "Aaron", time()+3600);'
    end

    assert_equal 1, header.headers.length
    assert_equal :store, header.headers.first.last
  end
end
