$:.unshift File.dirname(__FILE__)
require 'singleton'
require 'time'
require 'fileutils'
require 'yaml'
require 'configuration'
require 'entry'
require 'mapping_database'

# the database is in UTC
ENV["TZ"] = "UTC"

Dropbox::API::Config.app_key    = Configuration.values[:app_key] # "o5y30tzpxbqmz7r"
Dropbox::API::Config.app_secret = Configuration.values[:app_secret] # "ilbq1j1xf5kbuyk"
Dropbox::API::Config.mode       = Configuration.values[:app_mode] # "sandbox"

# this needs to be required after the dropbox api is setup
require 'sync'
