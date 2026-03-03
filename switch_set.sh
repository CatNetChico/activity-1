#!/bin/bash

# Define the switch IP addresses
SWITCHES=("10.12.100.9" "10.12.100.10" "10.12.100.11")
PORTS=("2006" "2004" "2006")
PASSWORD="chico"

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
    
    # Set a timeout (in seconds) so the script doesn't hang forever if a switch is dead
    set timeout 10
    
    # Start the telnet session
    spawn telnet $IP $PORT

    # Send a carriage return to wake up the console line
    send "\r"

    # This block dynamically handles the login and privilege escalation
    expect {
        -re "Password:" {
            # If it asks for a password, send it and loop back
            send "$PASSWORD\r"
            exp_continue
        }
        -re ">" {
            # If in User EXEC mode, go to Privileged mode and loop back
            send "enable\r"
            exp_continue
        }
        -re "#" {
            # If in Privileged EXEC mode, we are ready to configure
            send "configure terminal\r"
        }
        timeout {
            # If nothing happens, press Enter again to force a prompt
            send "\r"
            exp_continue
        }
    }

    # Now we rely strictly on the configuration prompts before sending the next command
    expect "(config)#"
    send "spanning-tree mode rapid-pvst\r"    

    expect "(config)#"
    send "end\r"

    expect "#"
    send "write memory\r"

    expect "#"
    send "exit\r"
    
    # Close the expect session
    expect eof
EOF

    echo -e "\nConfiguration successfully processed for $IP.\n"
done

echo "All switch configurations complete!"