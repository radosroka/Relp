require 'relp/server'
require 'relp/relp_protocol'
require 'relp/exceptions'
require 'logger'


module Relp

  port = 5000
  @relp_server = Relp::RelpServer.new(port, ['syslog'])

  def server_run()
    while !stop?
      begin
        server, socket = @relp_server.accept
        new_client_thread(server, socket)
      rescue Relp::RelpProtocolError
        @logger.error("Some error")
      end
    end
  end

  def new_client_thread(server, socket)
    Thread.start(server, socket) do |server, socket|
      begin
        server.connect(socket)

        peer = socket.peer
        @logger.debug("Connection to #{peer} created")
      rescue Relp::ConnectionClosed
        @logger.debug("Connection to #{peer} Closed")
      ensure
        socket.server_shut_down
      end
    end
  end




end


