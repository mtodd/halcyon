# MsgQ, a simple Message Queue
# Run with: thin start -r start.ru -p 6422 -c example/mq/

require 'halcyon'

class MsgQ < Halcyon::Application
  
  CEmpty = "Empty".freeze
  CQueued = "Queued".freeze
  CEnqueued = "Enqueued".freeze
  CDequeued = "Dequeued".freeze
  
  attr_accessor :queue
  
  route do |r|
    r.match('/enqueue').to(:action => 'enqueue')
    r.match('/dequeue').to(:action => 'dequeue')
    r.match('/status').to(:action => 'status')
    r.match('/').to(:action => 'list')
  end
  
  def startup
    self.queue = []
    @logger.info "Queue created and flushed."
  end
  
  def enqueue
    self.queue << params
    ok(CEnqueued)
  end
  
  def dequeue
    ok(self.queue.shift)
  end
  
  def list
    ok(self.queue)
  end
  
  def status
    case self.queue.length
    when 0
      ok(CEmpty)
    else
      ok(CQueued)
    end
  end
  
end
