#encoding: utf-8

class PlaylistBuilder

  def initialize(config)
    @config = config
  end

  def get_current_day_and_hour
    days = %w{ monday tuesday wednesday thursday friday saturday sunday }
    t = Time.new
    day = days[t.wday - 1]
    hour = t.hour
    [day, hour]
  end

  def get_adv_blocks_files(day)
    adv_directory_path = File.join @config[:sync_dir], @config[:adv_blocks_dir], day
    Dir.mkdir adv_directory_path unless Dir.exist? adv_directory_path

    blocks_count = @config[:blocks_count].to_i
    blocks = []
    (blocks_count).times do |i|
      filename = File.join(adv_directory_path, "#{i}.advblock")
      FileUtils.touch filename unless File.exist? filename

      block = []
      File.open filename, 'r' do |file|
        file.each_line { |l| block << l.gsub("\n", '') }
      end
      blocks << block
    end
    blocks
  end

  def playlist_header
    #'[playlist]\n' +
    #'X-GNOME-Title=gradus_playlist\n' +
    # "NumberOfEntries=#{ count }\n"
    '<?xml version="1.0" encoding="UTF-8"?>' +
    '\n' +
    '<playlist xmlns="http://xspf.org/ns/0/" xmlns:vlc="http://www.videolan.org/vlc/playlist/ns/0/" version="1">' +
    '<trackList>'
  end

  def playlist_footer
    '</trackList></playlist>'
  end

  def format_track(path)
    "<track><location>file://#{ path }</location></track>"
  end

  def get_playlist_hour_part(tracks_index, hour_path, blocks)
    tracks_count = 0
    music_files = Dir.entries(hour_path).sort
    music_files.delete_if { |f| f == '.' or f == '..' }
    tracks_array = music_files.map { |f| File.join(hour_path, f) }

    puts blocks.inspect
    #puts "Tracks Array #{ tracks_array.inspect }"
    #puts "Tracks Array length #{ tracks_array.length }"
    #puts "--"


    insert_positions = Array.new(blocks.length)
    # Последняя позиция вставки - после всех музыкальных треков
    insert_positions[blocks.length - 1] = tracks_array.length
    delay = tracks_array.length / blocks.length

    #puts "Insert positions #{ insert_positions.inspect }"
    #puts "Insert positions length #{ insert_positions.length }"
    #puts "Delay: #{delay}"
    #puts "--"


    1.upto insert_positions.length - 1 do |i|
      insert_positions[i - 1] = delay * i
    end

    #puts "Insert positions #{ insert_positions.inspect }"
    #puts "Insert positions length #{ insert_positions.length }"
    #puts "--"

    (insert_positions.length - 1).downto(0) do |i|
      tracks_array.insert(insert_positions[i], blocks[i])
    end
    tracks_array.flatten!

    #puts "Tracks Array #{ tracks_array.inspect }"
    #puts "Tracks Array length #{ tracks_array.length }"
    #puts "--"

    tracks_array.map! do |item|
      tracks_index += 1
      tracks_count += 1
      format_track item
    end


    #puts "Tracks Array #{ tracks_array.inspect }"
    #puts "Tracks Array length #{ tracks_array.length }"
    #puts "--"

    [tracks_index, tracks_array.join("\n") , tracks_count - 1]
  end

  def build_playlist(current_day, current_hour, end_hour)
    pl_path = @config[:playlist_path]
    music_path = File.join @config[:sync_dir], @config[:music_dir], current_day
    blocks_files = self.get_adv_blocks_files current_day
    blocks_files.map! { |block| block.map! { |item| File.join(@config[:sync_dir], item) } }

    tracks_count = 0
    playlist_str = ''

    tracks_index = 1

    (current_hour..end_hour).each do |h|
      hour_path = File.join music_path, h.to_s
      FileUtils.mkdir_p hour_path unless Dir.exist? hour_path
      tracks_index, hour_pl_str, hour_tracks_count = self.get_playlist_hour_part(tracks_index, hour_path, blocks_files)

      playlist_str += hour_pl_str
      tracks_count += hour_tracks_count
    end

    playlist_str = playlist_header() + playlist_str + playlist_footer()

    File.open(pl_path, 'w') do |f|
      playlist_str.split('\n').each { |line| f.write("#{line}\n") }
    end
    playlist_str
  end

end