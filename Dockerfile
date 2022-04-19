FROM debian:buster-slim

ARG myinstall="install --no-install-recommends"

#Update and reduce image size
RUN apt update \
    && apt $myinstall -y \
    && apt $myinstall apt-utils -y \
    && apt $myinstall cron -y \
    && apt install git -y \
    && apt $myinstall sudo -y

#add the pi user
RUN useradd -ms /bin/bash pi 
WORKDIR /home/pi


# Plainpad
RUN apt clean \    
    && apt $myinstall nodejs -y \
    && git clone https://github.com/alextselegidis/plainpad.git    \ 
    # delete .git specific files to make the image smaller
    && rm -r /home/pi/plainpad/.git 

RUN apt install php php-cgi php-fpm php-sqlite3 -y 
RUN apt install wget -y
RUN apt install php-curl -y
RUN wget -O composer-setup.php https://getcomposer.org/installer
RUN sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN apt install php-zip -y
RUN apt update && sudo apt upgrade -y
RUN chmod -R 770 plainpad \
    && cd plainpad 

WORKDIR /home/pi/plainpad
RUN composer self-update --1
RUN sudo apt install php-mbstring -y
RUN sudo apt install php-dom -y
RUN ./project setup  
# Expose the below port
EXPOSE 3000

# Set up startup script to run two commands, cron and the lighttpd server
ADD start.sh /home/pi
RUN chmod +x /home/pi/start.sh

CMD ["/home/pi/start.sh"]
