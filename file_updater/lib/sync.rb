# encoding: utf-8

require "fileutils"

module Sync

  EXCLUDED_LOCAL_PATHS=[".", ".."]
  @@client = Dropbox::API::Client.new(:token  => Configuration.values[:access_token], :secret => Configuration.values[:access_secret])
  @@dir = Configuration.values[:sync_dir]

  @@base_path = ""
  @@log_filename = Configuration.values[:shop_log_filename]
  @@shop_address = Configuration.values[:shop_addr]
  @@log_text = ""

  def self.fetch_from_remote
    
    files_found = []

    folders_to_search = [@@base_path]


    while folder = folders_to_search.pop
      @@client.ls(folder).each do |entry|
        #puts entry.path

        files_found << entry.path
        local_path = File.join(@@dir, entry.path)
        e = Entry.new :remote_entry => entry, :local_path => local_path

        if entry.is_a? Dropbox::API::Dir
          folders_to_search << entry.path
        end

        if e.remote_newer?
          e.update_local do
            if entry.is_a? Dropbox::API::Dir
	          begin
              FileUtils.mkdir_p local_path
                rescue Errno::EEXIST => e # if it's a directory and already exists, let's ignore
	            raise e unless File.directory? local_path
	          end
            else
              File.open(local_path, "w") {|f|
                entry_path = entry.path
                f.write(@@client.download(entry_path))
                puts "Файл #{ entry.path } успешно загружен\n"
                @@log_text += "Файл #{ entry.path } успешно загружен\n"
              }
            end

            File.mtime local_path
          end
        end
      end
    end

    files_found
  end

  def self.delete_from_local(files_found)
    Entry.all.each do |e|
      unless files_found.include? e.path
        e.delete do

          puts "Deleting: #{ File.join(@@dir, e.path) }"
          @@log_text += "Файл #{ File.join(@@dir, e.path) } удален\n"
          FileUtils.rm_rf File.join(@@dir, e.path)
        end
      end
    end
  end

  def self.push_from_local
    files_found = []
    folders_to_search = [@@dir + '/log/']
    while folder = folders_to_search.pop
      Dir.foreach(folder) do |f|
        next if EXCLUDED_LOCAL_PATHS.include? f
        puts folder

        local_path = File.join(folder,f)
        remote_path = local_path[@@dir.size + 1..local_path.size]
        files_found << remote_path

        e = Entry.new :remote_path => remote_path, :local_path => local_path

        if File.directory? local_path
          folders_to_search << local_path
        end

        if e.local_newer?
          e.update_remote do
            if File.directory? local_path
              begin
                @@client.mkdir remote_path
              rescue Dropbox::API::Error::Forbidden => e
                # this is a fake change, due to improper handling of directory mtime changes caused by subdirectories or files
                raise e unless e.message.include? "already exists."
              end
              if File.dirname(remote_path) == "."
	        @@client.search(File.basename(remote_path)).first.modified
              else
                @@client.search(File.basename(remote_path), :path => File.dirname(remote_path)).first.modified
              end
            else
              @@client.upload(remote_path, open(local_path).read)
              @@client.find(remote_path).modified
            end
          end
        end
      end
    end
    files_found
  end

  def self.delete_from_remote(files_found)
    Entry.all.each do |e|
      unless files_found.include? e.path
        e.delete do
          begin
            @@client.raw.delete :path => e.path
          rescue Dropbox::API::Error::NotFound # it was already deleted
          end
        end
      end
    end
  end

  def self.write_log_file
    current_time = Time.now + (4*60*60) # add 4 hours
    current_time = current_time.strftime("%Y-%m-%d в %H:%M:%S")
    puts "Время завершения обновления: #{current_time}"
    @@log_text = current_time + "\n" + @@log_text
  
    puts "Адрес магазина: #{ @@shop_address }"
    @@log_text = @@shop_address + "\n" + @@log_text
    
    dir_path = @@dir + '/log/'
    puts dir_path

    Dir.mkdir dir_path unless Dir.exist? dir_path

    log_file = dir_path + @@log_filename
    puts log_file

    File.open(log_file , 'w') { |f|
      f.write @@log_text
    }
  end

  def self.push_log_file_from_local

  end

  def self.sync!
    puts "\n Sync.fetch_from_remote calling\n"
    files = Sync.fetch_from_remote

    puts "\n Sync.delete_from_local calling\n"
    Sync.delete_from_local(files)

    puts "\n Sync.write_log_file calling\n"
    Sync.write_log_file

    puts "\n Sync.push_from_local calling\n"
    files = Sync.push_from_local
#    Sync.delete_from_remote(files)



  end
end

