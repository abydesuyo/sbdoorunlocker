# sbdoorunlocker
Switchbot Door Automation project using Wifi Authentication on your RPI running DNS / DHCP

Things to NOTE

1) This automation is for anyone using RPI as DNS / DHCP and has a Switchbot lock with Switchbot API activated.
2) Recommended to use devices like phone that will retain connection to Wifi unlike a smart watch
3) I am using arp to list connections, if your DHCP configuration is messy, then you should use MAC Address instead of Names

How to RUN

1) Git clone into directory where you would like to run it from
2) mkdir auth; mkdir log;
3) Ensure that you have a list of approved devies  (either MAC or Name registerd in your DHCP) in "approved.txt" - you can change these in the monitor.csh
4) Ensure that you have execute permissions for monitor.sh and that you have either replaced "MAIN_DOOR" with your door name or sourced it before running the script
5) python3 is the recommended environment; if which python3 doesnt exist or is empty, please install it first
6) ./monitor.sh in the directory to run, rm running to stop the program.
7) You can setup to run from CRON or setup as a systemcmd in which case, wrap it in another script that will 'cd; to the working directory first.


