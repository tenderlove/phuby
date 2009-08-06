require 'helper'

class TestPHPHandler < Phuby::TestCase
  FakeServer = Struct.new(:config)

  class FakeRequest
    attr_accessor :request_uri, :query, :path
    def initialize uri
      @request_uri = URI.parse "http://localhost#{uri}"
      @query = @request_uri.query ? Hash[
        *@request_uri.query.split('&').map { |param| param.split('=') }.flatten
      ] : {}
      @path = @request_uri.path
    end
  end

  class FakeResponse < Struct.new(:body, :headers)
    def [] k
      headers[k]
    end

    def []= k,v
      headers[k] = v
    end
  end

  def setup
    @server = FakeServer.new(
      :DocumentRoot => HTDOCS_DIR
    )
  end

  def test_get
    req = FakeRequest.new('/index.php?a=b&c=phuby')
    res = FakeResponse.new('', {})

    handler = Phuby::PHPHandler.new @server
    handler.do_GET req, res

    assert_match 'Get Params', res.body
    %w{ a b c phuby }.each do |thing|
      assert_match "<td>#{thing}</td>", res.body
    end
  end

  def test_headers_happen
    req = FakeRequest.new('/index.php?a=b&c=phuby')
    res = FakeResponse.new('', {})

    handler = Phuby::PHPHandler.new @server
    handler.do_GET req, res
    assert_not_nil res['Content-type']
  end
end
