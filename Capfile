# load 'deploy' if respond_to?(:namespace) # cap2 differentiator
require 'rubygems'
require 'railsless-deploy'

set :stage_dir, "config/stages"
require 'capistrano/ext/multistage'

set :rvm_ruby_string, '1.9.3'
require 'rvm/capistrano'

Dir['lib/capistrano/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy' # remove this line to skip loading any of the default tasks
