# multicast.rb
# 
# FIFOから得た値をWebsocketでマルチキャストする
# FIFO -> JSON -> Websocket -> All User

require 'em-websocket'
require 'json'

EventMachine.run {
  @channel = EM::Channel.new

  @row = {}
  @row["date"]    = Time.now
  @row["outlet1"] = 0
  @row["outlet2"] = 0
  @row["outlet3"] = 0
  @row["outlet4"] = 0
  @row["name1"] = "none"
  @row["name2"] = "none"
  @row["name3"] = "none"
  @row["name4"] = "none"
  
  # Thread monitoring FIFO
  read_thread = Thread.new do
    @fifo = open("FifoTest", "r")
    @fifo.each do |line|
      line.chomp!
      lineAry = line.split(" ", 4)
      
      @row["date"]    = Time.now
      @row["outlet1"] = lineAry[0].to_i
      @row["outlet2"] = lineAry[1].to_i
      @row["outlet3"] = lineAry[2].to_i
      @row["outlet4"] = lineAry[3].to_i
      
      puts JSON.pretty_generate(@row)
      @channel.push JSON.generate(@row)
    end
  end

  EventMachine::WebSocket.start(:host => "192.168.0.212", :port => 3000, :debug => true) do |ws|

    ws.onopen {
      sid = @channel.subscribe { |msg| ws.send msg }
      #@channel.push "#{sid} connected!"

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
