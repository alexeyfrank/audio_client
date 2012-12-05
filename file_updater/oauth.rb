require "rubygems"
require "bundler/setup"
Bundler.require(:default)
require File.dirname(__FILE__) + '/lib/initializer'

consumer = Dropbox::API::OAuth.consumer(:authorize)
request_token = consumer.get_request_token
puts "\nGo to this url and click 'Authorize' to get the token:"
puts request_token.authorize_url

query = request_token.authorize_url.split('?').last
params = CGI.parse(query)
token = params['oauth_token'].first
print "\nOnce you authorize the app on Dropbox, press enter... "
$stdin.gets.chomp

access_token = request_token.get_access_token(:oauth_verifier => token)

Configuration.write(:access_token, access_token.token)
Configuration.write(:access_secret, access_token.secret)

puts "\nAuthorization complete!:\n\n"

#puts "\nPlease enter the full path of the local directory to sync."
#dir = $stdin.gets.chomp
#Configuration.write(:sync_dir, dir)

puts "\n Please, edit config file for this shop!"

Configuration.write(:sync_dir, "/home/gradus/gradus_real_music")
Configuration.write(:shop_addr, "Shop Address Here")
Configuration.write(:shop_log_filename, "Shop log filename here")

Configuration.write(:adv_blocks_dir, 'adv_blocks')
Configuration.write(:music_dir, 'music')
Configuration.write(:playlist_path, '/home/gradus/gradus_playlist.xspf')
Configuration.write(:blocks_count, 4)

# puts "\nDone. You can try it by typing 'bundle exec ruby -Ilib cron.rb'"
