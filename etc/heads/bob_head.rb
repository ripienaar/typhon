class Typhon
    grow(:name => "bob", :files => "/var/log/mcollective.log") do |file, pos, line|
        stomp.publish("/topic/foo", "bob ate #{line}")
    end
end
