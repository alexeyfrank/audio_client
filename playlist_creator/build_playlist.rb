#encoding: utf-8

require "yaml"
require "fileutils"

require File.dirname(__FILE__) + "/lib/configuration"
require File.dirname(__FILE__) + "/playlist_builder"

config = {
    :playlist_path => Configuration.values[:playlist_path],
    :sync_dir => Configuration.values[:sync_dir],
    :music_dir => Configuration.values[:music_dir],
    :adv_blocks_dir => Configuration.values[:adv_blocks_dir],
    :blocks_count => Configuration.values[:blocks_count]
}

pl_builder = PlaylistBuilder.new config

current_day, current_hour = pl_builder.get_current_day_and_hour
pl_builder.build_playlist(current_day, current_hour, 20)
