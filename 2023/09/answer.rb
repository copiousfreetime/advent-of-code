#!/usr/bin/env ruby
require 'optparse'
require 'debug'

class History
  attr_reader :timeline
  attr_reader :numbers

  def initialize(input)
    @input = input.strip
    @numbers = @input.split(/\s+/).map(&:strip).map(&:to_i).compact
    @timeline = reduce(@numbers)
  end

  def reduce(numbers)
    [].tap do |lines|
      current_list = numbers.dup

      loop do
        lines << current_list
        break if current_list.sum.zero?
        current_list = reduce_one(current_list)
      end
    end
  end

  def reduce_one(n)
    n.each_cons(2).map { |a, b| b - a}
  end

  def inflate(&block)
    next_num = 0

    @timeline.reverse.each_cons(2) do |row_a, row_b|
      yield(row_a, row_b)
    end
  end

  def inflate_last
    inflate do |row_a, row_b|
      a = row_a.last
      b = row_b.last

      row_a << a if row_a.sum.zero?
      row_b << a + b
    end
  end

  def inflate_first
    inflate do |row_a, row_b|
      a = row_a.first
      b = row_b.first

      row_a.unshift(a) if row_a.sum.zero?
      row_b.unshift(b - a)
    end
  end

  def max_history
    @timeline.first.last
  end

  def min_history
    @timeline.first.first
  end

  def dump
    timeline.each do |row|
      puts row.join(' ')
    end
  end
end

options = {}
prompt = "Part 1 (inflate last value)"

OptionParser.new do |opts|
  opts.banner = "Usage: answer.rb [options]"

  opts.on("-f",  "--first", "Part 2 (inflate first value)") do |f|
    options[:first] = f
    prompt = "Part 2 (inflate last value)"
  end

  opts.on("-d", "--debug",  "Debug") do |d|
    options[:debug] = d
  end
end.parse!

histories = ARGF.map { |line| History.new(line) }

values = []
histories.each do |h|
  h.dump if options[:debug]
  if options[:first] then
    h.inflate_first
    values << h.min_history
  else
    h.inflate_last
    values << h.max_history
  end
  if options[:debug]
    puts "-" * 80
    h.dump
    puts
    puts "*" * 80
    puts
  end
end

puts "#{prompt} : #{values.sum}"
