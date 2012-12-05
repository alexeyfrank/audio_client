# encoding: utf-8
require "rubygems"
require "bundler/setup"
Bundler.require(:default)
require File.dirname(__FILE__) + '/lib/initializer'

Sync.sync!
