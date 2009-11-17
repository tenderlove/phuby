require 'phuby'

class PHPHandler < ActionView::TemplateHandler
  class Events < Struct.new(:code, :headers, :body)
    def write string; body << string; end
    def send_headers response_code;   end

    def header value, op
      k, v = value.split(': ', 2)
      self.code = 302 if k == 'Location'
      headers[k] = [headers[k], Rack::Utils.unescape(v)].compact.join "\n"
    end
  end

  def render template, *args
    filename = File.join template.load_path, template.template_path
    events   = Events.new(200, {}, '')
    Dir.chdir(File.dirname(filename)) do
      Phuby::Runtime.php do |rt|
        rt.eval "date_default_timezone_set('America/Los_Angeles');"
        rt.with_events(events) do
          open(filename) { |f| rt.eval f }
        end
      end
    end

    events.body
  end
end

ActionView::Template.register_template_handler('php', PHPHandler)
