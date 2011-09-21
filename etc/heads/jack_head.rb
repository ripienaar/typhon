class Typhon
    grow(:name => "jack", :files => "/var/log/mcollective-audit.log") do |file, pos, line|
        puts "jack ate #{line}"
        stomp.publish("/topic/foo", "jack ate #{line}")
    end
end
