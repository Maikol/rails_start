require 'bundler/capistrano'

default_run_options[:pty] = true
set :default_environment, {
  "PATH" => "/opt/rbenv/shims:/opt/rbenv/bin:$PATH"
}


set :application, "rails-starter-app"
set :repository, "git@github.com:Maikol/rails_start.git"
set :user, "ubuntu"
set :use_sudo, false
set :ssh_options, { :forward_agent => true }
set :branch, "chef_repo"

server "ec2-54-207-68-229.sa-east-1.compute.amazonaws.com", :web, :app, :db, :primary => true
ssh_options[:keys] = ["/Users/migueldeelias/Downloads/de-forms.pem"]

after "deploy:finalize_update", "symlink:all"

namespace :symlink do
  task :db do
    run "ln -nfs /u/apps/de-fomularios_production/shared/config/database.yml #{release_path}/config/database.yml"
  end
  task :all do
    symlink.db
  end
end

namespace :deploy do

  task :start do
    run "#{current_path}/bin/unicorn -Dc #{shared_path}/config/unicorn.rb -E #{rails_env} #{current_path}/config.ru"
  end

  task :restart do
    run "kill -USR2 $(cat #{shared_path}/pids/unicorn.pid)"
  end

end

after "deploy:restart", "deploy:cleanup"