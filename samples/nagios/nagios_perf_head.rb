require 'json'

class Typhon
    grow(:name => "nagios_perf", :files => "/var/tmp/typhon_input") do |file, pos, line|
        if line =~ /^\d+/
            exitcodes = {"OK" => 0, "WARNING" => 1, "CRITICAL" => 2, "UNKNOWN" => 3}
            alert_data = {}

            timestamp, host, check, output, exitcode, perfdata = line.split("\t")

            parsed_perf = {}

            if perfdata
                perfdata.split(/ /).each do |perf|
                    perf.scan(/'*([^=']+?)'*=([^a-zA-Z]+?)[a-zA-Z\%]*?;/).each do |metric|
                        parsed_perf[ metric[0].strip ] = metric[1].strip
                    end
                end
            end

            alert_data["eventtime"] = timestamp.to_i
            alert_data["subject"] = host
            alert_data["name"] = check
            alert_data["text"] = output
            alert_data["severity"] = exitcodes[exitcode].to_i
            alert_data["metrics"] = parsed_perf
            alert_data["origin"] = "monitor1.xx.net"
            alert_data["type"] = "status"
            alert_data["tags"] = {}

            stomp.publish("/topic/nagios.checks", alert_data.to_json)
        end
    end
end
