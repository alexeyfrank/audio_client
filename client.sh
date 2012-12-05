#!/bin/sh

$KCODE='u'

cd /home/gradus/gradus_audio_client/file_updater/
bundle exec ruby ./cron.rb -Ku

cd ../playlist_creator/
ruby ./build_playlist.rb

cd ../music_player
ruby ./player.rb
