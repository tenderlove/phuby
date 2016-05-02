require 'phuby'

class PHPHandler
  class Events < Struct.new(:code, :headers, :body)
    def write string; body << string; end
    def send_headers response_code;   end

    def header value, op
      k, v = value.split(': ', 2)
      self.code = 302 if k == 'Location'
      headers[k] = [headers[k], Rack::Utils.unescape(v)].compact.join "\n"
    end
  end

  class ControllerProxy
    def initialize controller
      @controller = controller
    end

    def method_missing name
      @controller.instance_variable_get :"@#{name}"
    end
  end

  attr_reader :filename

  def initialize filename, controller
    @controller = controller
    @proxy      = ControllerProxy.new @controller
    @filename   = filename
  end

  def run
    events   = Events.new(200, {}, '')
    rd, wr = IO.pipe

    buf = ''
    th = Thread.new do
      Thread.current.abort_on_exception = true

      while !rd.eof?
        buf << rd.read
      end
    end

    # PHP messes up openssl, so lets fork to protect the main Ruby process.
    pid = fork {
      rd.close

      Dir.chdir(File.dirname(filename)) do
        Phuby::Runtime.php do |rt|
          rt.eval "date_default_timezone_set('America/Los_Angeles');"
          rt['at'] = @proxy
          rt.with_events(events) do
            open(filename) { |f| rt.eval f }
          end
        end
      end

      str = events.body
      str.force_encoding 'utf-8'
      str.scrub!
      wr.write str
      wr.close
    }
    wr.close
    Process.waitpid pid
    th.join
    buf
  end

  def self.call template
    "PHPHandler.new(#{template.identifier.inspect}, controller).run"
  end
end

ActionView::Template.register_template_handler('php', PHPHandler)
