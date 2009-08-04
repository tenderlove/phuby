module Phuby
  class Events
    ###
    # Called when PHP wants to write something out
    def write string
      $stdout.write string
    end

    ###
    # Called when PHP wants to manipulate headers
    def header header, op
    end

    ###
    # Called when PHP wants to send response headers with +response_code+
    def send_headers response_code
    end
  end
end
