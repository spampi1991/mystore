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

ssh_options[:keys] = %w(/home/francesco/i-024922b078ed8a292.pem)
default_run_options[:shell] = '/bin/bash --login'
default_environment['RAILS_ENV'] = 'production'

task :symlink_master_key do
  run "ln -sfn #{shared_path}/config/master.key #{release_path}/config/master.key"
end
after "bundle:install", "symlink_master_key"

namespace :unicorn do
  desc "Zero-downtime restart of Unicorn"
  task :restart, except: { no_release: true } do
    run "kill -s USR2 `cat /tmp/unicorn.[application's name].pid`"
  end

  desc "Start unicorn"
  task :start, except: { no_release: true } do
    run "cd #{current_path} ; bundle exec unicorn_rails -c config/unicorn.rb -D"
  end

  desc "Stop unicorn"
  task :stop, except: { no_release: true } do
    run "kill -s QUIT `cat /tmp/unicorn.[application's name].pid`"
  end
end

after "deploy:restart", "unicorn:restart"

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
