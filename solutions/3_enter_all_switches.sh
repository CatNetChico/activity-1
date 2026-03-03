#!/bin/bash

# Define the switch IP addresses
SWITCHES=("10.12.100.13" "10.12.100.13" "10.12.100.13")
PORTS=("2003" "2004" "2011")

for i in "${!SWITCHES[@]}"; do
    IP=${SWITCHES[$i]}
    PORT=${PORTS[$i]}

    echo "========================================"
    echo " Configuring $IP on Port $PORT..."
    echo "========================================"

    # Export variables so the Expect subprocess can see them
    export IP PORT PASSWORD

    # We use a Here-Doc (<< EOF) to pass the Expect script directly from Bash
    /usr/bin/expect << EOF
    
    set timeout 10
    
    spawn telnet $IP $PORT

    send "\r"

    expect {
        -re ":" {
            send "chico\r"
            exp_continue
        }
        -re ">" {
            send "?\r"
        }
        timeout {
            send "\r"
            exp_continue
        }
    }

    expect "#"
    send "exit\r"
    
    expect eof
EOF

    echo -e "\nConfiguration successfully processed for $IP.\n"
done

echo "All switch configurations complete!"