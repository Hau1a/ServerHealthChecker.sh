#!/bin/bash

LOG_FILE="/var/log/health_check.log"

{
	echo "===Health Check Perort==="
	echo "Date: $(date)"

	#check gateway
	GATEWAY=$(ip route | awk '/default/ {print $3}')
	echo -n "Gateway $GATEWAY:"
	ping -c 3 -W 1 "$GATEWAY" &>/dev/null && echo "OK" || echo "FAIL"

	#check nginx
	echo -n "Nginx process: "
	if ps aux | grep nginx &>/dev/null; then
		echo "RUNNING (PID: $(pgrep nginx))"
	else
		echo "STOPPED"
	fi

	#check the port 80
	echo -n "Port 80: "
	ss -tln | awk '$4 ~ /:80/ {print "LISTEN"}'

	# Top processes by memory
	echo  "TOp 5 memory consumers: "
	ps aux --sort=-%mem | awk 'NR<=6 {printf "%-50s %-8s %-6s\n",$11,$2,$4}'
	echo "===End Report==="
	echo ""
}| sudo tee -a "$LOG_FILE" > /dev/null
