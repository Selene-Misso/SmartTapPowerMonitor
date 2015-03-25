# CoffeeMakerMonitor.rb
# 
# Websocketでコーヒーメーカーの電力消費をモニタし，
# コーヒーが出来たことを検出する．
# Websocket Client -> CoffeeMonitor -> Push to Slack or Twitter

require 'websocket-client-simple'
require 'json'
require 'slack-notifier'

# Slack webhook URL
WEBHOOK_URL = 'https://hooks.slack.com/services/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'

# コーヒーの状態を監視するクラス
class CoffeeMonitor
	# 初期化
	# 引数: ave_sec 平均を取る秒数
	def initialize(ave_sec)
		@state = "WAIT"
		@array = Array.new(ave_sec, 0)
		@p     = 0

		# Slack 連携
		@notifier = Slack::Notifier.new WEBHOOK_URL
		@notifier.ping "待機中 : 起動しました"
	end
	
	# 状態を変更
	def changeState(val)
		# 配列に格納
		@array[(@p % @array.length)] = val
		@p += 1
		if @p == @array.length then
			@p = 0
		end
		
		case @state
		when "WAIT"  # 待ち状態
			if val >= 6000
				@state = "DRIP"
				@notifier.ping "ドリップ中"
			end
		
		when "DRIP"  # ドリップ状態
			if val == 0
				@state = "KEEP"
				@notifier.ping "保温中 : コーヒーが湧いたよ"
			end
		
		when "KEEP"  # 保温状態
			# array.size 秒間の平均を計算
			ave = 0
			@array.each {|x| ave += x}
			ave = ave / @array.length
			puts ave
			if ave <= 500
				@state = "WAIT"
				@notifier.ping "待機中"
			end
		
		else
			@state = "WAIT"
		
		end
	end
	
	def getState
		return @State
	end
end

monitor = CoffeeMonitor.new(70)

puts "websocket-client-simple v#{WebSocket::Client::Simple::VERSION}"

url = ARGV.shift || 'ws://192.168.0.212:3000'

ws = WebSocket::Client::Simple.connect url

ws.on :message do |msg|
#	puts ">> #{msg.data}"
	data = JSON.parse(msg.data)
#	puts JSON.pretty_generate(data)
	
	# コンセント名が coffee を含むものを取り出す
	if    data['name1'].include?("Coffee")
		amp = data['outlet1']
	elsif data['name2'].include?("Coffee")
		amp = data['outlet2']
	elsif data['name3'].include?("Coffee")
		amp = data['outlet3']
	elsif data['name4'].include?("Coffee")
		amp = data['outlet4']
	else
		amp = nil
	end
#	p amp
	if amp != nil
		monitor.changeState(amp)
#		p monitor.getState
	end
end

ws.on :open do
	puts "-- websocket open (#{ws.url})"
end

ws.on :close do |e|
	puts "-- websocket close (#{e.inspect})"
	exit 1
end

ws.on :error do |e|
	puts "-- error (#{e.inspect})"
end

loop do
	ws.send STDIN.gets.strip
end