# multicast.rb
# 
# FIFOから得た値をWebsocketでマルチキャストする
# まだFIFOからの受取はできてない

require 'em-websocket'

EventMachine.run {
  @channel = EM::Channel.new

  open("FifoTest", "r+") do |fifo|
    fifo.each do |line|
      @channel.push "Time: #{line}."
    end
  end
#  @twitter = Twitter::JSONStream.connect(
#    :path => '/1/statuses/filter.json?track=ruby',
#    :auth => "#{username}:#{password}",
#    :ssl => true
#  )

#  @twitter.each_item do |status|
#    status = JSON.parse(status)
#    @channel.push "#{status['user']['screen_name']}: #{status['text']}"
#  end


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
