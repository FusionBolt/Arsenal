require 'set'

class StateMachine
  attr_reader :state
  attr_reader :callbacks

  # init
  def initialize(init_state)
    @states = Hash.new do |hash, key|
      hash[key] = Set.new
    end
    @callbacks = Hash.new do |hash, key|
      hash[key] = []
    end
    @state = init_state
  end

  # register_callback
  def register(state, &block)
    @callbacks[state] << block
  end

  # add transfer
  def add(start_state, end_state)
    @states[start_state] << end_state
  end

  def transfer(next_state)
    raise "#{@state} can't reach #{next_state}" unless @states[@state].include? next_state
    @callbacks[next_state].each do |f|
      f.call(@state, next_state)
    end
    @state = next_state
  end

  def transfer?(next_state)
    @states[@state].include? next_state
  end

  def reached_states
    s = Set.new
    @states.each do |_, v|
      s.merge(v)
    end
    s
  end
end

def get_m
  m = StateMachine.new(:start)
  m.add(:start, :state1)
  m.add(:start, :state2)
  m.add(:state1, :state3)
  m.add(:state2, :end)
  m.reached_states.each do |state|
    m.register(state) do
      p "to #{state}"
    end
  end
  m
end

def demo
  m = get_m
  %i[state2 end].each do |state|
    m.transfer(state)
  end

  m = get_m
  %i[state1 state3].each do |state|
    m.transfer(state)
  end

  m = get_m
  begin
    %i[state1 state2 state3].each do |state|
      m.transfer(state)
    end
  rescue => ex
    p ex
  end
end