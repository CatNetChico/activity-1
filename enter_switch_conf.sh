#!/bin/bash

# Define the switch IP addresses

PASSWORD="chico"

IP="10.12.100.13"
PORT="2003"

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
        send "$PASSWORD\r"
        exp_continue
    }
    -re ">" {
        send "enable\r"
        exp_continue
    }
    -re "#" {
        send "configure terminal\r"
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