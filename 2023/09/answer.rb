#!/usr/bin/env ruby

class History
  attr_reader :timeline
  attr_reader :numbers

  def initialize(input)
    @input = input.strip
    @numbers = @input.split(/\s+/).map(&:strip).map(&:to_i).compact
    @timeline = []
  end

  def reduce
    current_list = @numbers.dup
    loop do
      @timeline << current_list
      break if current_list.sum.zero?
      current_list = reduce_one(current_list)
    end
  end

  def reduce_one(n)
    n.each_cons(2).map { |a, b| b - a}
  end

  def inflate
    next_num = 0

    @timeline.reverse.each_cons(2) do |row_a, row_b|
      last_a = row_a.last
      last_b = row_b.last

      if row_a.sum.zero? then
        row_a << last_a
      end

      row_b << last_a + last_b
    end
  end

  def max_history
    @timeline.first.last
  end
end

histories = ARGF.map { |line| History.new(line) }
histories.each do |h|
  h.reduce
  #puts h.timeline.map{ |x| x.join(", ") }.join("\n")
  #puts "=" * 42
  h.inflate
  #puts h.timeline.map{ |x| x.join(", ") }.join("\n")
end

puts histories.map(&:max_history).sum
