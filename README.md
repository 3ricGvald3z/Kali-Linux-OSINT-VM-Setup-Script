# Kali Linux OSINT VM Setup Script

This is a comprehensive and automated setup script for a new Kali Linux virtual machine, designed to streamline the installation of a wide range of Open-Source Intelligence (OSINT) tools. It combines various installation methods—including `apt`, `pipx`, `go`, `snap`, and `git`—into a single, robust script.

<div align="center"> <pre> 
                              ______________                               
                        ,===:'.,            `-._                           
EGV                        `:.`---.__         `-._                       
 Kali Linux OSINT              `:.     `--.         `.                     
                                 \.        `.         `.                   
                         (,,(,    \.         `.   ____,-`.,                
                      (,'     `/   \.   ,--.___`.'                         
                  ,  ,'  ,--.  `,   \.;'         `                         
                   `{D, {    \  :    \;                                    
                     V,,'    /  /    //                                    
                     j;;    /  ,' ,-//.    ,---.      ,                    
                     \;'   /  ,' /  _  \  /  _  \   ,'/                    
                           \   `'  / \  `'  / \  `.' /                     
                            `.___,'   `.__,'   `.__,'  VM

</pre>

## Features

-   **Automated Installation:** Installs a large collection of OSINT tools without manual intervention.
    
-   **Dependency Management:** Manages Python dependencies using isolated virtual environments for many tools to prevent conflicts.
    
-   **Go Toolchain:** Installs and configures a variety of Go-based tools.
    
-   **Service Configuration:** Sets up essential services like UFW (firewall), SSH, PostgreSQL, and MongoDB for immediate use.
    
-   **DNS Configuration:** Configures the system to use public DNS servers for improved reliability.
    
-   **Error Handling and Logging:** Includes a robust error-checking mechanism and logs all output to a file for easy troubleshooting.
    

## Prerequisites

-   A fresh installation of Kali Linux (2024.x or later is recommended).
    
-   A stable internet connection.
    
-   The script **must** be run with root privileges (`sudo`).
    

## How to Use

1.  Download the script:
    
    Save the kali_osint_setup_enhanced.sh file to your Kali VM.
    
2.  Make it Executable:
    
    Open a terminal and make the script executable with the following command:
    
    ```
    chmod +x kali_osint_setup_enhanced.sh
    
    ```
    
3.  Run the Script:
    
    Execute the script with sudo:
    
    ```
    sudo ./kali_osint_setup_enhanced.sh
    
    ```
    
    The script will log its progress to the terminal and to the file `/var/log/kali_osint_setup.log`.
    

## What the Script Does

The script performs the following actions in a structured order:

1.  **Initial Setup:** Updates `apt` package lists and verifies root privileges.
    
2.  **System-wide Packages:** Installs a list of common tools and dependencies using `apt`. It also purges some pre-installed tools to use more up-to-date versions later.
    
3.  **MongoDB Installation:** Adds the official MongoDB repository and installs the database server, enabling it to start automatically on boot.
    
4.  **Service Configuration:** Starts and enables key services like UFW, Snapd, PostgreSQL, and SSH. It also initializes the Metasploit database and configures DNS settings.
    
5.  **Go Toolchain:** Installs a collection of Go-based tools and moves them to the appropriate binary path.
    
6.  **Language-specific Tools:** Installs tools using `npm`, `gem`, `snap`, and `cargo`.
    
7.  **Python and Git Tools:** Clones various GitHub repositories into a `~/programs` directory and installs their Python dependencies in isolated virtual environments.
    
8.  **Repository Cloning:** Clones several useful resources, cheatsheets, and tool collections into designated directories.
    
9.  **Ronin Installation:** Downloads and runs the installation script for the Ronin toolkit.
    

## Post-Installation

After the script finishes, you should perform the following steps:

1.  **Reboot your system:**
    
    ```
    sudo reboot
    
    ```
    
    This ensures all services and system changes take full effect.
    
2.  Add Go binaries to your PATH:
    
    The script installs Go tools to ~/go/bin. To make these tools available from any terminal, add the following line to your ~/.bashrc or ~/.zshrc file:
    
    ```
    export PATH="$HOME/go/bin:$PATH"
    
    ```
    
    Then, apply the changes by running:
    
    ```
    source ~/.bashrc  # or source ~/.zshrc
    
    ```
    

## Troubleshooting

If the script encounters an error, it will exit and log the failure. You can review the full log file to diagnose the issue:

```
cat /var/log/kali_osint_setup.log

```
