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

                #Update script, and install cronie ;

                /usr/bin/pacman -Syyu --noconfirm ;

                /usr/bin/pacman -Sc --noconfirm ;

                /usr/bin/pacman -S cronie --noconfirm ;
		
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
        /usr/bin/echo 'Starting Cronie Service......' ;
 	/usr/bin/echo '                      ' ;
				##Enable and start Cronie
				/usr/bin/systemctl enable cronie.service ;
                                /usr/bin/systemctl start cronie.service ;
	/usr/bin/echo 'Creating symbolic link from vim to vi......' ;
 	/usr/bin/echo '                      ' ;
                                /usr/bin/ln -s /usr/bin/vim /usr/bin/vi ; ## Creates a symbolic link for vim to vi. Cronie often has issues with using vim. Feel free to remove this line if you like and use vi.
	/usr/bin/echo 'Creating cronjob to run autopac automatically everyday at 4:00 am. To change this time edit your crontab by executing crontab -e ' ;
 	/usr/bin/echo '                      ' ;
                                (crontab -l 2>/dev/null; echo "0 4 * * * /usr/bin/autopac") | crontab - ; ##This line sets the frequency to run autoapt in crontab. Feel free to change this to your preference
                        
echo 'Installation Complete. Please check your Crontab and make sure timing is acceptable for your setup!' ;
