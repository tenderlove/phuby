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
    end

    def initialize server, root = server.config[:DocumentRoot] || Dir.pwd, *args
      super
    end

    def do_GET req, res
      return super(req, res) unless req.path =~ /\.php$/

      file = File.join(@root, req.path)

      Dir.chdir(@root) do
        Phuby::Runtime.php do |rt|
          req.query.each do |k,v|
            rt['_GET'][k] = v
          end

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
