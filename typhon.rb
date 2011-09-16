#!/usr/bin/ruby

require 'typhon'
require 'optparse'

@headsdir = "/etc/typhon"

opt = OptionParser.new

opt.on("--heads [DIR]", "Directory full of Typhon heads") do |v|
    @headsdir = v
end

opt.parse!

raise "The directory #{@headsdir} does not exist" unless File.directory?(@headsdir)

t = Typhon.new(@headsdir)

puts "Tailing #{Typhon.files.join ', '}"

t.tail
