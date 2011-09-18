#!/usr/bin/ruby

require 'typhon'
require 'optparse'

configdir = "/etc/typhon"

opt = OptionParser.new

opt.on("--config [DIR]", "Directory for configuration file and heads") do |v|
    configdir = v
end

opt.parse!

raise "The directory #{configdir} does not exist" unless File.directory?(configdir)

t = Typhon.new(configdir)

Typhon.files.each do |f|
    Typhon::Log.info("Tailing log #{f}")
end

t.tail
