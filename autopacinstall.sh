#!/bin/bash

##if not root, run as root
if (( $EUID != 0 )); then
        sudo /bin/echo "Try Running As Root!"
                exit
                fi
       /usr/bin/echo 'Establishing log directory at /var/log/pacman-auto-update' ;
       /usr/bin/echo '                      ' ;
                /usr/bin/mkdir /var/log/pacman-auto-update ;

                /usr/bin/touch /usr/bin/autopac ;

                #Update script ;

                /usr/bin/pacman -Syyu --noconfirm ;

                /usr/bin/pacman -Sc --noconfirm ;
            	
		##The below script creates /usr/bin/autopac
  
	/usr/bin/echo 'Creating autopac executable at /usr/bin/autopac' ;
 	/usr/bin/echo '                      ' ;
                
		/usr/bin/echo '#!/bin/bash
                #if not root, run as root
                if (( $EUID != 0 )); then
                        sudo /bin/echo "Try Running As Root!"
                                exit
                                fi

                                ##Set log file variables
                                export TIMESTAMP=$(date +'%Y_%m_%d--%H-%M-%S')
                                export LOGDIR=/var/log/pacman-auto-update
                                export LOGFILE=${LOGDIR}/update_${TIMESTAMP}.log

                                ##Update script
                                {

                                /usr/bin/pacman -Syyu --noconfirm ;

                                /usr/bin/pacman -Sc --noconfirm ;


                                } | tee ${LOGFILE} ; #Redirect all script output to the log file

                                echo '                      ' ;

                                echo 'Update Complete!' ;

                                exit 0' >> /usr/bin/autopac && /usr/bin/chmod +x /usr/bin/autopac ; ##Completion of /usr/bin/autoapt, making it executable

/usr/bin/echo 'Creating and enabling systemd timer to run 5 minutes after system boot and every 24 hours thereafter......' ;
 /usr/bin/echo '                      ' ;

##Create Systemd timer to run automatically 5 mins after system boot and every 24 hours thereafter 
/usr/bin/touch /etc/systemd/system/autopac.service ;
/usr/bin/touch /etc/systemd/system/autopac.timer ;

/usr/bin/echo '[Unit]
Description="Run autopac.service 5min after boot and every 24 hours relative to activation time"

[Timer]
OnBootSec=5min
OnUnitActiveSec=24h
OnCalendar=Mon..Fri *-*-* 10:00:*
Unit=autopac.service


[Install]
WantedBy=multi-user.target' >> /etc/systemd/system/autopac.timer ;

/usr/bin/echo '[Unit]
Description="Auto Pacman update Script"

[Service]
ExecStart=/usr/bin/autopac' >> /etc/systemd/system/autopac.service ;

##Enable and start autopac timer
				
/usr/bin/systemctl start autopac.timer ;
/usr/bin/systemctl enable autopac.timer ;

                               
                        
echo 'Installation Complete!' ;
