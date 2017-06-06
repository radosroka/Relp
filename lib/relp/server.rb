module Relp
  class RelpServer < RelpProtocol

    def initialize(port, required_commands=[])
      @logger = Logger.new(STDOUT)

      @required_commands = required_commands

      begin
        @server = TCPServer.new port
      rescue Errno::EADDRINUSE
        @logger.error  "ERROR Could not start relp server: Address #{port} in use" #add port number
        raise
      end
    end

    def create_frame(socket, txnr, command, message)
      frame = {:txnr => txnr,
          :command => command,
          :message => message
      }
      Relp::frame_write(socket,frame)
    end

    def ack(socket, txnr)
      frame = {:txnr => txnr,
           :command => 'rsp',
           :message => '200 OK'
      }
      frame_write(socket, frame)
    end

    def server_close(socket)
      frame = {:txnr => 0,
               :command => "serverclose"
      }
      begin
        Relp::frame_write(socket,frame)
        socket.close
      end
    end

    def accept_connection
      @logger.debug("New socket")
      socket = @server.accept
      return socket
    end

    def connect(socket)
      frame = Relp::frame_read(socket)
      if frame[:command] == 'open'
        offer=Hash[*frame[:message].scan(/^(.*)=(.*)$/).flatten]
        if offer['relp_version'].nil?
          server_close(socket)
          raise Relp::ConnectionRefused
        else
          response_frame = create_frame(socket,frame[:txnr], "rsp", "200 OK" + 'relp_version=' + @relp_version + "\n" 'relp_software=' + @relp_software)
        end
      elsif frame[:command] == 'syslog'
        return frame
      elsif frame[:command] == 'close'
        response_frame = create_frame(socket,frame[:txnr], "rsp", "200 OK")
        Relp::frame_write(socket,response_frame)
        server_close(socket)
        raise Relp::ConnectionClosed
      else
        server_close(socket)
        raise Relp::RelpProtocolError
      end
    end



    def close_connection
      @server.close
    end

    def server_shut_down
      if @relp_server
        @relp_server.shutdown
        @relp_server = nil
      end
    end


  end
end
