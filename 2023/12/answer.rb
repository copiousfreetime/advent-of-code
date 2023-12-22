#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'debug'
  gem 'memery', require: true
end

class Solution
  include Memery

  memoize def arrangements_line(record:, groups:)

    #puts "record: #{record} groups: #{groups}"
    if record.empty? && groups.empty? then
      return 1
    end

    if  record.empty? && groups.any? then
      return 0
    end

    if groups.empty? && !record.include?('#') then
      return 1
    end

    if groups.empty? then
      return 0
    end

    char, rest = record[0], record[1..-1]

    case char
    when "."
      return arrangements_line(record: rest, groups: groups)

      # '#' means we are counting if we have the current group
    when "#"
      g_size = groups.first
      return 0 unless record.length >= g_size # bail if we can't make the size
      return 0 if record[0,g_size].include?(".") # bail since theres no potential to match

      # we're probably at the end - but values are returned when nothing is left
      if (record.length == g_size) then
        #puts "going down -- probably to terminate"
        return arrangements_line(record: record[g_size..-1], groups: groups[1..-1])
        # if the next item isn't a '#' then we can move to the next group
      elsif (record[g_size] != '#')
        #puts "going down -- #{record} #{g_size} #{record[g_size]}"
        return arrangements_line(record: record[(g_size+1)..-1], groups: groups[1..-1])
      end

      return 0
    when "?"
      hash_count = arrangements_line(record: "##{rest}", groups: groups, )
      dot_count  = arrangements_line(record: ".#{rest}", groups: groups)
      return (hash_count + dot_count)
    else
      raise "oops! #{char}"
    end

  end
end

total = 0
solution = Solution.new
ARGF.each_line do |line|
  spring_raw, checks_raw = line.strip.split(/\s+/, 2)

  spring_raw = Array.new(5) { spring_raw }.join('?')
  checks_raw = Array.new(5) { checks_raw }.join(",")

  checks = checks_raw.split(",").map(&:to_i)

  row_total = solution.arrangements_line(record: spring_raw, groups: checks)
  puts "#{row_total} : #{spring_raw} #{checks}"
  #row_total = arrangements(part2_s, part2_c)

  total += row_total
end
puts total
