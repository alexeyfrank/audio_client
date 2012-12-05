#!/bin/bash

echo -e "Hello! This is setup script for insoftretail audio client. Press any key to continue... \c "
read any_key

echo "Installing VLC media player... \n"
sudo apt-get install vlc

echo "Install RVM libs...\n"

sudo apt-get install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion

echo "Download and install rvm... \n"
curl -L get.rvm.io | bash -s stable

echo "Load rvm in bash... \n"
source /home/gradus/.rvm/scripts/'rvm'

echo "Modifying .bashrc file for autoloading rvm... \n"
echo "source ~/.rvm/scripts/'rvm'" >> ~/.bashrc

echo "Installing ruby... \n"
rvm install 1.9.3-head

echo "use ruby 1.9.3... \n"
rvm use 1.9.3-head --default

echo "Install project files: \n"


echo -e "Did you CHANGE config file?[1, 0]: \c "
read res

if [ $res -eq 1 ] ; then

    file_updater_db="./file_updater/mappings.db"

    if [ -e $file_updater_db ]; then
        rm $file_updater_db
    fi

    cd ./file_updater
    bundle install
    bundle exec ruby oauth.rb

    echo "Write in /etc/rc.local file sh /path/to/client.sh"

fi
