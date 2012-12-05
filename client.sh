#!/bin/sh

$KCODE='u'

cd ./file_updater/
bundle exec ruby ./cron.rb -Ku

cd ../playlist_creator/
ruby ./build_playlist.rb

cd ../music_player
ruby ./player.rb
