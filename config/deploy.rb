require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'

set :domain, '69.195.134.174'
set :user, 'starterpad'
set :port, '25362'
# https://github.com/nadarei/mina/issues/99
set :term_mode, :nil
set :repository, 'git@gitlab.com:imkane/starterpad2.git'
set :puma_threads, '0:18'
set :pid_file, '/tmp/pids/puma.pid'
set :clockwork_pids_dir, '/tmp/pids'
set :clockwork_log_dir, '/log'
set :clockwork_identifier, 'starterpad_clockwork'
set :clockwork_file, 'starterpad_clockwork'
set :socket_file, '/tmp/sockets/puma.sock'

set :shared_paths, ['config/database.yml', 'log', 'tmp/pids', 'tmp/sockets', 'public/uploads', 'public/robots.txt', 'db/lagacy']

task :environment do  
  case ENV['to']
    when 'production'
      set :deploy_to, '/var/www/starterpad.com'
      set :branch, 'master'
      set :rails_env, 'production'
    else
      set :deploy_to, '/var/www/dev.starterpad.com'
      set :branch, 'dev'
      set :rails_env, 'staging'
  end
  queue! %[echo "-----> #{rails_env} environment"]
  set :current_dir, "#{deploy_to}/#{current_path}"
  set :clockwork_pids_directory, current_dir + clockwork_pids_dir
  set :clockwork_pids_directory_env, clockwork_pids_directory + "/#{rails_env}"
  set :clockwork_logs_directory, current_dir + clockwork_log_dir
  set :clockwork_logs_directory_env, clockwork_logs_directory + "/#{rails_env}"

  invoke :'rbenv:load'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]
  
  queue! %[mkdir -p "#{deploy_to}/shared/public/uploads"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/pids"]
  queue! %[mkdir -p "#{deploy_to}/shared/tmp/sockets"]
  
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/sockets"]


  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue! %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
  
  invoke :'create_dir:clockwork'

end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    to :launch do
      if ENV['new'] == 'true'
        invoke :'server:start'        
      else
        invoke :'server:phased_restart'                        
      end
      if rails_env == 'production'
        invoke :'clockwork:restart' 
      end
    end
  end
end

desc "Shows logs."
task :logs => :environment do
  queue %[cd #{deploy_to!} && tail -f shared/log/#{rails_env}.log]
end

desc "Rails Console."
task :console => :environment do
  queue %[cd #{deploy_to}/#{current_path} && RAILS_ENV=#{rails_env} bundle exec rails c]
end

namespace :create_dir do
  desc "Create Required Directory"
  task :clockwork => :environment do
    queue %Q,
      if [ ! -d "#{clockwork_pids_directory}" ] ; then
        echo "Creating #{clockwork_pids_directory}"
        mkdir -p #{clockwork_pids_directory}
      fi,
    queue %Q,
      if [ ! -d "#{clockwork_pids_directory_env}" ] ; then
        echo "Creating #{clockwork_pids_directory_env}"
        mkdir -p #{clockwork_pids_directory_env}
      fi,
    queue %Q,
      if [ ! -d "#{clockwork_logs_directory}" ] ; then
        echo "Creating #{clockwork_logs_directory}"
        mkdir -p #{clockwork_logs_directory}
      fi,
    queue %Q,
      if [ ! -d "#{clockwork_logs_directory_env}" ] ; then
        echo "Creating #{clockwork_logs_directory_env}"
        mkdir -p #{clockwork_logs_directory_env}
      fi,
  end
end

namespace :clockwork do 
  task :status => :environment do
    queue! %[ cd #{current_dir} && RAILS_ENV=#{rails_env} bundle exec clockworkd --pid-dir=#{clockwork_pids_directory_env} --identifier=starterpad_clockwork_#{rails_env} --log-dir=#{clockwork_logs_directory_env} --dir=#{current_dir} --log -c lib/clockwork.rb status ]
  end
  task :stop => :environment do
    queue! %[ cd #{current_dir} && RAILS_ENV=#{rails_env} bundle exec clockworkd --pid-dir=#{clockwork_pids_directory_env} --identifier=starterpad_clockwork_#{rails_env} --log-dir=#{clockwork_logs_directory_env} --dir=#{current_dir} --log -c lib/clockwork.rb stop ]
  end
  task :start => :environment do
    queue! %[ cd #{current_dir} && RAILS_ENV=#{rails_env} bundle exec clockworkd --pid-dir=#{clockwork_pids_directory_env} --identifier=starterpad_clockwork_#{rails_env} --log-dir=#{clockwork_logs_directory_env} --dir=#{current_dir} --log -c lib/clockwork.rb start ]
    invoke :'clockwork:status'
  end
  task :restart => :environment do
    invoke :'clockwork:stop'
    invoke :'clockwork:start'

    # BUG: stops clockwork if running.
    # queue! %[ cd #{current_dir} && RAILS_ENV=#{rails_env} bundle exec clockworkd --pid-dir=#{clockwork_pids_directory_env} --identifier=starterpad_clockwork_#{rails_env} --log-dir=#{clockwork_logs_directory_env} --dir=#{current_dir} --log -c lib/clockwork.rb restart ]
  end
  task :log => :environment do
    queue! %[ cd #{current_dir} && tail -f #{clockwork_logs_directory_env}/clockworkd.starterpad_clockwork_#{rails_env}.output]
  end
  task :twitter_log => :environment do
    queue! %[cd #{deploy_to!} && tail -f shared/log/scheduled_job_twitter.log]
  end
  task :morning_mail_log => :environment do
    queue! %[cd #{deploy_to!} && tail -f shared/log/scheduled_job_morning_mail.log]
  end

end

namespace :server do
  desc "Start the application"
  task :start => :environment do
    queue! "cd #{deploy_to}/#{current_path} && RAILS_ENV=#{rails_env} bundle exec puma -t #{puma_threads} -e #{rails_env} -d -b unix://#{deploy_to}/shared#{socket_file} --pidfile #{deploy_to}/shared#{pid_file}"
    queue! "sleep 10"
    queue! "sudo echo -1000 > /proc/`cat #{deploy_to}/shared#{pid_file}`/oom_score_adj"
  end
 
  desc "Stop the application"
  task :stop => :environment do
    queue! "cd #{current_dir} && RAILS_ENV=#{rails_env} bundle exec pumactl -P #{deploy_to}/shared#{pid_file} stop"  
  end
 
  desc "Restart the application"
  task :restart => :environment  do
    queue! "cd #{current_dir} && RAILS_ENV=#{rails_env} bundle exec pumactl -P #{deploy_to}/shared#{pid_file} restart"
  end

  desc "Phased Restart the application"
  task :phased_restart => :environment  do
    queue! "cd #{current_dir} && RAILS_ENV=#{rails_env} bundle exec pumactl -P #{deploy_to}/shared#{pid_file} phased-restart"
  end
 
  desc "Status of the application"
  task :status => :environment do
    queue! "cd #{current_dir} && RAILS_ENV=#{rails_env} bundle exec pumactl -P #{deploy_to}/shared#{pid_file} status"
  end

  desc "Rollback to last release"
  task :rollback => :environment do
    queue! "ln -snfv \"releases/$( expr `readlink current | awk -F/ '{print $2}'` - 1 )\" current"
    invoke :'server:phased_restart'
  end
end

