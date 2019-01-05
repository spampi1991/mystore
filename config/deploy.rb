require "bundler/capistrano"
load "deploy/assets"

set :application, "mystore"
set :repository,  "https://github.com/spampi1991/mystore.git"
set :scm, :git 
server = "ec2-18-206-226-204.compute-1.amazonaws.com"

role :web, server                          # Your HTTP server, Apache/etc
role :app, server                          # This may be the same as your `Web` server
role :db, server, :primary => true         # This is where Rails migrations will run

set :user, "spree"

set :deploy_to, "/home/spree/#{application}"
set :use_sudo, false
set :linked_files, %w{config/master.key}

ssh_options[:keys] = %w(/home/francesco/i-024922b078ed8a292.pem)
default_run_options[:shell] = '/bin/bash --login'
default_environment['RAILS_ENV'] = 'production'

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
