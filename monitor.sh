#!/bin/bash

WEBHOOK_URL="https://discord.com/api/webhooks/1454881725330100308/xhHSmVZlh1zFITKChFQdvrgM2Upu1hAJZs7Lcpb4ugB8zNDeBG6FOeAS1Pa72y-NFd6X"

dis_alert()
{
  local MESSAGE=$1
  curl -s -X POST -H "Content-Type: application/json" \
    -d '{"content": "'"$MESSAGE"'"}' \
    "$WEBHOOK_URL"
}

while true;
do
# Get Status
        status=$(curl -s -o /dev/null -w "%{http_code}" http://192.168.1.18/)

# Server is Up
        if [ "$status" -eq 200 ];
        then
                echo "Server is UP"

# Server got a problem (5xx)
        elif [ "$status" -ge 500 ] && [ "$status" -lt 600 ];
        then
                echo "DATE: $(date "+%D TIME: %T") [Problem] Server got a problem (Status = $status)" >> log.txt
                dis_alert "DATE: $(date "+%D TIME: %T") [Problem] Server got a problem (Status = $status)"

                for attempt in 1 2 3;
                do
                        echo "DATE: $(date "+%D TIME: %T") [Attempt] Attempting Restart" >> log.txt
                        dis_alert "DATE: $(date "+%D TIME: %T") [Attempt] Attempting Restart"

                        docker compose restart
                        sleep 10

                        status=$(curl -s -o /dev/null -w "%{http_code}" http://192.168.1.18/)

                        if [ "$status" -eq 200 ];
                        then
                                echo "DATE: $(date "+%D TIME: %T") [Resolved] Server is UP!! Problem resolved" >> log.txt
                                dis_alert "DATE: $(date "+%D TIME: %T") [Resolved] Server is UP!! Problem resolved"
                                break
                        fi
                done

                if [ "$status" -ne 200 ];
                then
                        echo "DATE: $(date "+%D TIME: %T") [Failed] Recovery failed after 3 attempts" >> log.txt
                        dis_alert "DATE: $(date "+%D TIME: %T") [Failed] CRITICAL: Service still unhealthy after 3 restarts"
                	break 
		fi

# No response / connection refused
        else
                echo "DATE: $(date "+%D TIME: %T") [Problem] Server is unreachable (Connection Refused) Status=$status" >> log.txt
		dis_alert "DATE: $(date "+%D TIME: %T") [Problem] Server is unreachable (Connection Refused) Status=$status" 

                for attempt in 1 2 3;
                do
                        echo "DATE: $(date "+%D TIME: %T") [Attempt] Attempting Restart" >> log.txt
                        dis_alert "DATE: $(date "+%D TIME: %T") [Attempt] Attempting Restart"

                        docker compose restart
                        sleep 10

                        status=$(curl -s -o /dev/null -w "%{http_code}" http://192.168.1.18/)

                        if [ "$status" -eq 200 ];
                        then
                                echo "DATE: $(date "+%D TIME: %T") [Resolved] Server is UP!! Problem resolved" >> log.txt
                                dis_alert "DATE: $(date "+%D TIME: %T") [Resolved] Server is UP!! Problem resolved"
				break
                        fi
                done

		 if [ "$status" -ne 200 ];
                then
                        echo "DATE: $(date "+%D TIME: %T") [Failed] Recovery failed after 3 attempts" >> log.txt
                	dis_alert "DATE: $(date "+%D TIME: %T") [Failed] CRITICAL: Service still unhealthy after 3 restarts"
			break
		fi
        fi

        sleep 15
done

