require "fileutils"

require "../lib/extensions"
require "./file_system_test"
require "../playlist_builder"


class PlaylistBuilderTest < FileSystemTest
  def before

    set_config({
        :dropbox_dir => '/home/frank/gradus_test/',
        :adv_dir => '/home/frank/gradus_test/adv/',
        :rel_adv_dir => 'adv',
        :music_dir => '/home/frank/gradus_test/music/',
        :adv_blocks_dir => '/home/frank/gradus_test/adv_blocks/',
        :adv_blocks_count => 4,
        :adv_block_files_range => (3..4),
        :music_files_range => (17..17),
        :days => %w{ monday tuesday wednesday thursday friday saturday sunday },
        :hours_range => (8..20),
        :music_filename => "music_track",
        :adv_block_filename => "adv_track",
        :adv_block_ext => 'advblock',
        :ext => 'mp3'
    })

    @test_config = {
        :playlist_path => '/home/frank/test_playlist.xspf',
        :sync_dir => @c[:dropbox_dir],
        :music_dir => 'music',
        :adv_blocks_dir => 'adv_blocks',
        :blocks_count => @c[:adv_blocks_count]
    }

    FileUtils.rm_rf @c[:dropbox_dir] if Dir.exist? @c[:dropbox_dir]
  end

  def mock
    FileUtils.mkdir_p @c[:adv_dir]
    FileUtils.mkdir_p @c[:music_dir]
    FileUtils.mkdir_p @c[:adv_blocks_dir]

    # create music
    @c[:days].each do |day|
      day_path = File.join @c[:music_dir], day
      @c[:hours_range].each do |hour|
        hour_path = File.join day_path, hour.to_s
        FileUtils.mkdir_p hour_path
        files_count = rand(@c[:music_files_range])
        (files_count - 1).times do |file_index|
          filename = File.join hour_path, "#{file_index}__#{ @c[:music_filename] }_#{ day }_#{ hour.to_s }.#{ @c[:ext] }"
          FileUtils.touch filename
        end
      end
    end

    #create adv blocks
    @c[:days].each do |day|
      day_path = File.join @c[:adv_blocks_dir], day
      FileUtils.mkdir_p day_path
      @c[:adv_blocks_count].times do |adv_block_index|
        filepath = File.join day_path, "#{adv_block_index}.#{ @c[:adv_block_ext] }"
        File.open(filepath, 'w') do |file|
          adv_block_files_count = rand @c[:adv_block_files_range]
          adv_block_files_count.times {|i|
            filename = "#{i}__#{@c[:adv_block_filename]}_#{day}_#{adv_block_index}.#{ @c[:ext]}"
            file.write("#{ File.join(@c[:rel_adv_dir], filename) }\n") }
        end
      end
    end
  end


  def tests

    it 'should be get a current day of week' do
      days = %w{ monday tuesday wednesday thursday friday saturday sunday }
      t = Time.new
      current_day = days[t.wday - 1]
      day = PlaylistBuilder.new({}).get_current_day_and_hour[0]

      should_be_equals(current_day, day)
    end

    it 'should get a current hour' do
      current_hour = Time.new.hour
      hour = PlaylistBuilder.new({}).get_current_day_and_hour[1]
      should_be_equals(current_hour, hour)
    end

    it 'should be get a correct adv_blocks count for monday' do
      pl_builder = PlaylistBuilder.new @test_config
      blocks = pl_builder.get_adv_blocks_files('monday')
      should_be_equals(@c[:adv_blocks_count], blocks.length)
    end

    it 'should be get a not empty adv_blocks for monday' do
      pl_builder = PlaylistBuilder.new @test_config
      blocks = pl_builder.get_adv_blocks_files('monday')
      should_be_equals(blocks.length, @c[:adv_blocks_count])
      blocks.each { |block| assert (block.length != 0) }
    end

    it 'should get playlist part for monday, 8 hour and started from 1 index (NEW METHOD)' do
      pl_builder = PlaylistBuilder.new(@test_config)

      hour_path = File.join(@test_config[:sync_dir], @test_config[:music_dir], 'monday', 8.to_s)
      blocks = pl_builder.get_adv_blocks_files('monday')
      pl_builder.get_playlist_hour_part(1, hour_path, blocks)
      #puts pl_builder.get_playlist_hour_part_new(1, hour_path, blocks).inspect

    end

    #it 'should get playlist part for monday, 8 hour and started from 1 index' do
    #  pl_builder = PlaylistBuilder.new(@test_config)
    #
    #  hour_path = File.join(@test_config[:sync_dir], @test_config[:music_dir], 'monday', 8.to_s)
    #  blocks = pl_builder.get_adv_blocks_files('monday')
    #
    #  pl_builder.get_playlist_hour_part(1, hour_path, blocks)
    #
    #end

    it 'should be build play list for monday, started at 8a.m.' do
      pl_builder = PlaylistBuilder.new(@test_config)
      day, hour = ['monday', 8]
      pl_builder.build_playlist(day, hour, 20)
    end

  end
end