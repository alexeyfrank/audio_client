require File.dirname(__FILE__) +"/lib/configuration"

class MusicPlayer

  def start(playlist_path)
    `cvlc #{playlist_path}`
  end
end

playlist_path = Configuration.values[:playlist_path]
player = MusicPlayer.new
player.start(playlist_path)

