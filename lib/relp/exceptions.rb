module Relp
  class RelpProtocolError < StandardError
  end

  class ConnectionClosed < RelpProtocolError
  end

  class FrameReadException < RelpProtocolError
  end

  class InvalidCommand < RelpError
  end
end
