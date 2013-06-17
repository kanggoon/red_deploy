ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "kanggoon.pem")]
ENV["SVN_SSH"] = "ssh -q -i " + ssh_options[:keys][0]

set :repository,  "git@github.com:kanggoon/red_server.git"
set :branch, "master"
#set :gateway, "admin@111.222.333.444"

set :deploy_via, :copy
set :copy_exclude, [".git", ".gitignore"]

set :deploy_to, "/var/www/red"

set :user, "ubuntu"
set :use_sudo, false

set :host, "ec2-54-218-10-68.us-west-2.compute.amazonaws.com"

role :web, fetch(:host)                     # Your HTTP server, Apache/etc
role :app, fetch(:host)                     # This may be the same as your `Web` server
role :db,  fetch(:host), :primary => true   # This is where Rails migrations will run

