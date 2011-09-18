class Typhon
    grow(:name => "bob", :files => "/var/log/mcollective.log") do |file, pos, line|
        puts "bob ate #{line}"
    end
end
