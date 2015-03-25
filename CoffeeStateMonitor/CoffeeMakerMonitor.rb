# CoffeeMakerMonitor.rb
# 
# Websocketでコーヒーメーカーの電力消費をモニタし，
# コーヒーが出来たことを検出する．
# Websocket Client -> CoffeeMonitor -> Push to Slack or Twitter

#require 'em-websocket'
require 'json'

# コーヒーの状態を監視するクラス
class CoffeeMonitor
	# 初期化
	# 引数: ave_sec 平均を取る秒数
	def initialize(ave_sec)
		@state = "WAIT"
		@array = Array.new(ave_sec, 0)
		@p     = 0
		p @array
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
			end
		
		when "DRIP"  # ドリップ状態
			if val == 0
				@state = "KEEP"
			end
		
		when "KEEP"  # 保温状態
			# array.size 秒間の平均を計算
			ave = 0
			@array.each {|x| ave += x}
			ave = ave / @array.length
			puts ave
			if ave <= 500
				@state = "WAIT"
			end
		
		else
			@state = "WAIT"
		
		end
		getState
	end
	
	def getState
		return @State
	end
end

monitor = CoffeeMonitor.new(55)
70.times{
monitor.changeState(350)
}
puts monitor.getState
monitor.changeState(10)
monitor.changeState(6100)
monitor.changeState(6130)
monitor.changeState(50)
monitor.changeState(0)

monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(6100)
monitor.changeState(6130)
monitor.changeState(50)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
monitor.changeState(0)
