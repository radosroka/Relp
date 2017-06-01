require '../lib/relp/exceptions'
module Relp

  class RelpProtocol
    @relp_version = '0'
    @relp_software = 'librelp,1.2.13,http://librelp.com'

    def frame_write(socket, frame)
      frame[:txnr] = frame[:txnr].to_s
      frame[:message] = '' if frame[:message].nil?
      frame[:frame_length] = frame[:message].length.to_s

      raw_data=[
          frame[:txnr],
          frame[:command],
          frame[:data_length],
          frame[:message]
      ].join(' ')
      begin
        @logger.debug("Writing data to socket", :data => raw_data)
        socket.write(raw_data)
        socket.write("\n")
      rescue Errno::EPIPE,IOError,Errno::ECONNRESET
        raise Relp::ConnectionClosed
      end
      return frame[:txnr].to_i
    end

    def frame_read(socket)#TODO extract version commands and relp software
      begin
        socket_content = socket.read
        frame = Hash.new
        if match = socket_content.match(/(^[0-9]+) ([\S]*) (\d+) ([\s\S]*)/)
          frame[:txnr], frame[:command], frame[:data_length], frame[:message] = match.captures
        end
        @logger.debug("Read frame", :frame => frame)
      rescue Errno::ECONNRESET
        raise Relp::ConnectionClosed.new('Connection closed')
      rescue EOFError,IOError
        raise Relp::FrameReadException
      end
      is_valid_command(frame[:command])

      return frame
    end

    def is_valid_command(command)
      valid_commands = Array.new
      if !valid_commands = ["open", "close", "rsp", "syslog"].include?(command)
        raise Relp::InvalidCommand.new('Invalid command')
      end
    end
  end
end
