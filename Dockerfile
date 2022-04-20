FROM debian:buster-slim

ARG myinstall="install --no-install-recommends"

#Update and reduce image size
RUN apt update \
    && apt $myinstall -y \
    && apt $myinstall apt-utils -y \
    && apt $myinstall cron -y \
    && apt install git -y \
    && apt $myinstall sudo -y

# Plainpad
RUN apt clean \    
    && apt $myinstall nodejs -y \
    && git clone https://github.com/alextselegidis/plainpad.git    \ 
    # delete .git specific files to make the image smaller
    && rm -r /plainpad/.git 

# php-cgi php-fpm php-sqlite3 -y 
RUN apt $myinstall php -y 
RUN apt install wget -y
RUN apt install php-curl -y
RUN wget -O composer-setup.php https://getcomposer.org/installer
RUN sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN apt install php-zip -y
RUN apt update && sudo apt upgrade -y
RUN chmod -R 770 plainpad 
# RUN     && cd plainpad 


RUN composer self-update --1
RUN sudo apt install php-mbstring -y
RUN sudo apt install php-dom -y
RUN apt install unzip -y
RUN apt install nodejs npm -y


# overwrite the setup.sh script - relative paths don't seem to be specified correctly, fixing
ADD setup.sh /plainpad/scripts/
RUN chmod +x /plainpad/scripts/setup.sh
RUN cd /plainpad && ./project setup  
# Expose the below port
EXPOSE 3000

# Set up startup script 
ADD start.sh /plainpad/
RUN chmod +x /plainpad/start.sh

CMD ["/plainpad/start.sh"]
