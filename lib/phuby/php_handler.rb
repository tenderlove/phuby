require 'webrick'

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
        @res[k] = v.strip
      end

      def write string
        @res.body ||= ''
        @res.body << string
      end

      def send_headers response_code
        #print "#" * 50
        #puts response_code
      end
    end

    def initialize server, root = server.config[:DocumentRoot] || Dir.pwd, *args
      super
    end

    def do_POST req, res
      return super(req, res) unless req.path =~ /\.php$/

      process :POST, req, res
    end

    def do_GET req, res
      return super(req, res) unless req.path =~ /\.php$/

      process :GET, req, res
    end

    private
    def process verb, req, res
      file = File.join(@root, req.path)

      Dir.chdir(@root) do
        Phuby::Runtime.php do |rt|
          rt.eval("date_default_timezone_set('America/Los_Angeles');")

          req.request_uri.query.split('&').each do |pair|
            k, v = pair.split '='
            rt["_GET"][k] = v
          end if req.request_uri.query

          req.query.each do |k,v|
            rt["_#{verb}"][k] = v
          end if :POST == verb

          events = Events.new req, res

          rt.with_events(events) do
            File.open(file, 'rb') { |f|
              rt.eval f
            }
          end
        end
      end
    end
  end
end
