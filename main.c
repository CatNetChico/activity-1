#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SWITCHES 3

// Define a structure to hold the switch connection details
struct Switch
{
    char id[10];
    char ip[20];
    int port;
};

void configure_switches(struct Switch switches[], int mode)
{
    char protocol[20];

    // Determine which protocol to push based on user selection
    if (mode == 1)
    {
        strcpy(protocol, "pvst");
    }
    else
    {
        strcpy(protocol, "rapid-pvst");
    }

    printf("\n--- Starting Automation for %s ---\n", protocol);

    for (int i = 0; i < MAX_SWITCHES; i++)
    {
        printf("Configuring %s at %s:%d...\n", switches[i].id, switches[i].ip, switches[i].port);

        // We construct a Linux 'expect' command string to handle the Telnet session.
        // Note: You will need to change "cisco" and "class" to your lab's actual passwords.
        char command[2048];
        snprintf(command, sizeof(command),
                 "expect -c '"
                 "spawn telnet %s %d;"
                 "expect \"*assword:\"; send \"cisco\\r\";"
                 "expect \"*>\"; send \"enable\\r\";"
                 "expect \"*assword:\"; send \"class\\r\";"
                 "expect \"*#\"; send \"ecc_reset\\r\";"
                 "expect \"*#\"; send \"configure terminal\\r\";"
                 "expect \"*(config)#\"; send \"spanning-tree mode %s\\r\";"
                 "expect \"*(config)#\"; send \"end\\r\";"
                 "expect \"*#\"; send \"show spanning-tree\\r\";"
                 "expect \"*#\"; send \"exit\\r\";"
                 "'",
                 switches[i].ip, switches[i].port, protocol);

        // Execute the automated session in the Linux terminal
        system(command);
        printf("Finished configuring %s.\n\n", switches[i].id);
    }
}

int main()
{
    // Populate the array with your lab's specific switch IP and Port details
    struct Switch switches[MAX_SWITCHES] = {
        {"XS1", "10.12.100.13", 2003}, // Update IP and Port as needed
        {"XS2", "10.12.100.13", 2004},
        {"XS3", "10.12.100.13", 2005}};

    int choice;

    // Interactive Menu Loop
    while (1)
    {
        printf("========================================\n");
        printf("    Network Automation Manager (C)\n");
        printf("========================================\n");
        printf("1. Configure Standard STP (pvst)\n");
        printf("2. Configure Rapid STP (rapid-pvst)\n");
        printf("3. Exit\n");
        printf("Enter your choice (1-3): ");

        if (scanf("%d", &choice) != 1)
        {
            printf("Invalid input. Exiting.\n");
            break;
        }

        if (choice == 1 || choice == 2)
        {
            configure_switches(switches, choice);
        }
        else if (choice == 3)
        {
            printf("Exiting Network Automation Manager.\n");
            break;
        }
        else
        {
            printf("Invalid choice. Please try again.\n");
        }
    }

    return 0;
}