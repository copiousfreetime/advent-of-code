#!/usr/bin/env ruby

require 'optparse'
require 'time'
require 'net/http'

options = {
  year: Time.now.utc.year,
  day: Time.now.utc.day,
}

OptionParser.new do |parser|
  parser.banner = "Usage: #{$0} [options]"

  parser.on("-yYEAR", "--year=YEAR", "Year of the AoC") do |y|
    options[:year] = y.to_i
  end

  parser.on("-dDay", "--day=DAY", "Day of the AoC") do |d|
    options[:day] = d.to_i
  end

  parser.on("-h", "--helper") do |h|
    puts parser
    exit
  end
end.parse!


uri     = URI.parse("https://adventofcode.com/#{options[:year]}/day/#{options[:day]}/input")
begin
  session = ENV.fetch('AOC_SESSION')
rescue KeyError => k
  puts "You need to set AOC_SESSION environment variables: #{k}"
  exit 1
end

headers = {
  Cookie: "session=#{session}",
  User_Agent: "fetch_aoc_input.rb by copiousfreetime",
}

input   = Net::HTTP.get(uri, headers)
puts input
