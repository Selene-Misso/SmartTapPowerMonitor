# multicast.rb
# 
# FIFOから得た値をWebsocketでマルチキャストする
# FIFO -> JSON -> Websocket -> All User

require 'em-websocket'

EventMachine.run {
  @channel = EM::Channel.new

  # Thread monitoring FIFO
  read_thread = Thread.new do
    @fifo = open("FifoTest", "r")
    @fifo.each do |line|
      @channel.push "Time: #{line}."
    end
  end

  EventMachine::WebSocket.start(:host => "192.168.0.212", :port => 3000, :debug => true) do |ws|

    ws.onopen {
      sid = @channel.subscribe { |msg| ws.send msg }
      @channel.push "#{sid} connected!"

      ws.onmessage { |msg|
        @channel.push "<#{sid}>: #{msg}"
      }

      ws.onclose {
        @channel.unsubscribe(sid)
      }
    }

  end

  puts "Server started"
}
