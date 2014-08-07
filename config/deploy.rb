require "bundler/capistrano"
set :application, "sakuralive"
set :repository, "git@github.com:binitkumar/sakuralive.git"
set :scm, :git
set :branch, "master"
set :deploy_via, :remote_cache
set :ssh_options, { :forward_agent => true }
set :deploy_to, "/var/www/#{application}" #path to your app on the production server 
set :use_sudo, true
set :rvm_type, :user

set :rake, "#{rake} --trace"

set :domain, '107.170.81.22'
role :web, domain
role :app, domain
role :db,  domain, :primary => true

default_run_options[:pty] = true

set :user, "root"

after "deploy:restart", "deploy:cleanup", "deploy:migrate", "deploy:symlink", "sitemaps:create_symlink"

namespace :sitemaps do
  task :create_symlink, roles: :app do
    run "mkdir -p #{shared_path}/sitemaps"
    run "rm -rf #{release_path}/public/sitemaps"
    run "ln -s #{shared_path}/sitemaps #{release_path}/public/sitemaps"
  end
end

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} chmod 777 -R #{File.join(current_path,'tmp')}"
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :migrate do
    run("cd #{deploy_to}/current && /usr/bin/env bundle exec rake db:migrate RAILS_ENV=production")
    #run("cd #{deploy_to}/current && /usr/bin/env bundle exec rake assets:precompile RAILS_ENV=production")
  end
  
  task :symlink, :except => { :no_release => true } do
    run "rm -rf #{release_path}/public/system"
    run "ln -nfs #{shared_path}/uploads #{release_path}/public/system"
  end
end
