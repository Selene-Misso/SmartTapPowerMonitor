# multicast.rb
# 
# FIFOから得た値をWebsocketでマルチキャストする
# FIFO -> JSON -> Websocket -> All User

require 'em-websocket'
require 'json'

EventMachine.run {
  @channel = EM::Channel.new

  @row = {}
  @outlet1 = {"power(W)" => 0, "name" => "none"}
  @outlet2 = {"power(W)" => 0, "name" => "none"}
  @outlet3 = {"power(W)" => 0, "name" => "none"}
  @outlet4 = {"power(W)" => 0, "name" => "none"}
  @row["date"]    = Time.now
  @row["outlet1"] = @outlet1
  @row["outlet2"] = @outlet2
  @row["outlet3"] = @outlet3
  @row["outlet4"] = @outlet4

  # Thread monitoring FIFO
  read_thread = Thread.new do
    @fifo = open("FifoTest", "r")
    @fifo.each do |line|
      line.chomp!
      lineAry = line.split(" ", 4)
      
      @row["date"]         = Time.now
      @outlet1["power(W)"] = lineAry[0].to_i
      @outlet2["power(W)"] = lineAry[1].to_i
      @outlet3["power(W)"] = lineAry[2].to_i
      @outlet4["power(W)"] = lineAry[3].to_i
      
      puts JSON.pretty_generate(@row)
      @channel.push JSON.generate(@row)
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
