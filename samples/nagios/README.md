A simple example using Nagios to write results of every check
it does to a file then using Typhon to parse this file and emit
events over Stomp to a event archive/handler.

First create a performance data handler for nagios:

    #! /bin/sh
    TIMET=$1
    HOSTNAME=$2
    SERVICEDESC=$3
    OUTPUT=$4
    SERVICESTATE=$5
    PERFDATA=$6

    /usr/bin/printf "%b" "$TIMET\t$HOSTNAME\t$SERVICEDESC\t$OUTPUT\t$SERVICESTATE\t$PERFDATA\n" >> /var/tmp/typhon_input

Now create the nagios command to call this script:

    define command{
        command_name   process-service-perfdata
        command_line   $USER1$/process-service-perfdata  "$LASTSERVICECHECK$" "$HOSTNAME$" "$SERVICEDESC$" "$SERVICEOUTPUT$" "$SERVICESTATE$" "$SERVICEPERFDATA$"
    }

And tell nagios to call your command after every check:

    service_perfdata_command=process-service-perfdata

Now install the _nagios\_perf\_head.rb_ and setup typhon with your
Stomp server and you should start seeing events on the topic.

Remember to rotate the log file that the above script creates
