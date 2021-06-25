require 'socket'

# test url
# http://gaia.cs.umass.edu/wireshark-labs/INTRO-wireshark-file1.html

# used for learn normal proxy
class HTTPProxy
  attr_accessor :port

  def initialize(port = 200)
    @port = port
  end

  def run
    server = TCPServer.open 2000
    loop do
      Thread.start(server.accept) do |client|
        connect_request = client.recvfrom(1024)[0]
        p connect_request
        hostname = connect_request.split[1]
        uri = URI(hostname)
        p hostname
        p uri.hostname, uri.port
        TCPSocket.open uri.hostname, uri.port do |server|
          p 'connect successful'
          server.write connect_request
          while data = server.read
            client.write data
            server.write client.read
          end
        end
      end
    end
  end
end