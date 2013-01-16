#!/usr/bin/env ruby

require 'rubygems'
require 'fastercsv'

filename = ARGV[0]
data = FasterCSV.read(filename)
header = data.delete_at(0)

longest = 0
header.each do |key|
  longest = key.length if key.length > longest
end

header.each_with_index do |key, index|
  if key.length < longest
    leftover = longest - key.length
    header[index] = key + ":" + (" " * leftover)
  else
    header[index] = key + ":"
  end
end

data.each do |record|
  puts "\n\n"
  record.each_with_index do |value, index|
    key = header[index]
    if value && value !~ /^\s*$/
      puts "#{key}\t#{value}\n"
    end
  end
end



