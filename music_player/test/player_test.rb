require File.dirname(__FILE__) + "/../player"
def test(name)
  puts "-- #{name}"
  yield
end

test 'player is started' do
  player = MusicPlayer.new
  puts player.started?.to_s
end

#test 'start player' do
#  player = MusicPlayer.new
#  puts player.started?.to_s
#  player.start_player
#  puts player.started?.to_s
#end

test 'init playlist' do
  playlist_path = Configuration.values[:playlist_path]
  player = MusicPlayer.new
  player.clear_playlist
  player.init_playlist(playlist_path)
end