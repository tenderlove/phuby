require 'webrick'
require 'cgi'
require 'logger'

module Phuby
  class PHPHandler < WEBrick::HTTPServlet::FileHandler
    class Events < Phuby::Events
      def initialize req, res
        super()
        @req = req
        @res = res
      end

      def header value, op
        k, v = *value.split(':', 2)
        if k.downcase == 'set-cookie'
          @res.cookies << v.strip
        else
          @res[k] = v.strip
        end
      end

      def write string
        @res.body ||= ''
        @res.body << string
      end

      def send_headers response_code
      end
    end

    def initialize server, root = server.config[:DocumentRoot] || Dir.pwd, *args
      super
    end

    def do_POST req, res
      req.path << "index.php" if req.path =~ /\/$/

      return super(req, res) unless req.path =~ /\.php$/

      process :POST, req, res
    end

    def do_GET req, res
      req.path << "index.php" if req.path =~ /\/$/

      return super(req, res) unless req.path =~ /\.php$/

      process :GET, req, res
    end

    private
    def process verb, req, res
      file = File.join(@root, req.path)

      Dir.chdir(File.dirname(file)) do
        Phuby::Runtime.php do |rt|
          rt.eval("date_default_timezone_set('America/Los_Angeles');")

          rt['logger'] = Logger.new($stdout)
          req.request_uri.query.split('&').each do |pair|
            k, v = pair.split '='
            rt["_GET"][k] = v
          end if req.request_uri.query

          req.query.each do |k,v|
            rt["_#{verb}"][k] = v
          end if :POST == verb

          # Set CGI server options
          req.meta_vars.each do |k,v|
            rt["_SERVER"][k] = v || ''
          end
          rt["_SERVER"]['REQUEST_URI'] = req.request_uri.path

          req.cookies.each do |cookie|
            rt["_COOKIE"][cookie.name] = CGI.unescape(cookie.value)
          end

          events = Events.new req, res

          rt.with_events(events) do
            File.open(file, 'rb') { |f|
              rt.eval f
            }
          end
        end
      end
      if res['Location']
        res['Location'] = CGI.unescape res['Location']
        res.status = 302
      end
    end
  end
end
