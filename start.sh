#!/bin/bash

function finish() {
        echo "bye bye!";
        exit 1;
}

while true; do 
    trap finish SIGINT

    if pgrep -x TimpiCollector > /dev/null ; then #check if it's already running
        sleep 60; #sleep for 60 seconds if it's running
    else 
        ./TimpiCollector ; #start it if it isn't running
	   
       if [ $? -ne 0 ]; then
	       exit 1 ;
	   fi;
    fi; 
done