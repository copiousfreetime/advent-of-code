#!/usr/bin/env ruby
require 'optparse'
require 'debug'

options = {}
OptionParser.new do |parser|
  parser.banner = "Usage: answer.rb [options]"

  parser.on("-w", "--[no-]words", "Parse Words") do |w|
    options[:words] = w
  end
end.parse!

digit_tokens = ('0'..'9').to_a
word_tokens = %w[
    zero
    one
    two
    three
    four
    five
    six
    seven
    eight
    nine
]

token_value_map = {}.tap do |h|
  [ digit_tokens, word_tokens ].each do |token_list|
    token_list.each.with_index do |token, value|
      h[token] = value
    end
  end
end

regex_tokens = digit_tokens

if options[:words]
  regex_tokens.concat(word_tokens)
end

reverse_tokens = regex_tokens.map(&:reverse)

forward_regex = Regexp.new("(#{regex_tokens.join("|")})")
reverse_regex = Regexp.new("(#{reverse_tokens.join("|")})")

values = []
ARGF.each_line do |line|
  line.strip!

  forward_token = forward_regex.match(line).captures.first
  forward_value = token_value_map[forward_token]

  reverse_token = reverse_regex.match(line.reverse).captures.first
  reverse_value = token_value_map[reverse_token.reverse]

  value           = "#{forward_value}#{reverse_value}".to_i
  values << value
end
puts values.sum

