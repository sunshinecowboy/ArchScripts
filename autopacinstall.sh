#!/bin/bash

##if not root, run as root
if (( $EUID != 0 )); then
        sudo /bin/echo "Try Running As Root!"
                exit
                fi

                /usr/bin/mkdir /var/log/pacman-auto-update

                /usr/bin/touch /usr/bin/autopac

                #Update script, and install cronie

                /usr/bin/pacman -Syyu --noconfirm ;

                /usr/bin/pacman -Sc --noconfirm ;

                /usr/bin/pacman -S cronie --noconfirm ;
		
		##The below command creates /usr/bin/autoapt

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
                                
				##Enable and start Cronie
				/usr/bin/systemctl enable cronie.service ;
                                /usr/bin/systemctl start cronie.service ;

                                /usr/bin/ln -s /usr/bin/vim /usr/bin/vi ; ## Creates a symbolic link for vim to vi. Cronie often has issues with using vim. Feel free to remove this line if you like and use vi.
                                (crontab -l 2>/dev/null; echo "35 15 * * * /usr/bin/autopac") | crontab - ; ##This line sets the frequency to run autoapt in crontab. Feel free to change this to your preference
                        
echo 'Installation Complete. Please check your Crontab and make sure timing is acceptable for your setup!' ;
