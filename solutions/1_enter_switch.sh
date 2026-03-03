#!/bin/bash

# Define the switch IP addresses
IP="10.12.100.13"

echo "========================================"
echo " Configuring $IP on Port 2003..."
echo "========================================"

# Export variables so the Expect subprocess can see them
export IP PORT

# We use a Here-Doc (<< EOF) to pass the Expect script directly from Bash
/usr/bin/expect << EOF

set timeout 10

spawn telnet $IP 2003

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