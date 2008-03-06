require 'msg_q'
run MsgQ.new(:logger => Logger.new(STDOUT))
