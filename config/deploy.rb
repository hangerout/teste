require "bundler/capistrano"

load "config/recipes/base"
load "config/recipes/nginx"
load "config/recipes/unicorn"
load "config/recipes/mysql"
load "config/recipes/nodejs"
load "config/recipes/redis"
load "config/recipes/rvm"
load "config/recipes/check"


server "ec2-54-232-218-235.sa-east-1.compute.amazonaws.com", :web, :app, :db, :primary => true
ssh_options[:keys] = ["#{ENV['HOME']}/hangerout.pem"]


set :user, "deployer"
set :application, "teste"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:hangerout/#{application}.git"
set :branch, "master"


default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases


namespace :deploy do

  namespace :assets do
    task :precompile, :roles => :web, :except => {:no_release => true} do
      begin
        from = source.next_revision(current_revision)
        error = false
      rescue
        error = true
      end
      force_precompile = false
      if error or capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0 or force_precompile
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info " ***************** Skipping asset pre-compilation because there were no asset changes ****************"
      end
    end
  end
end

def run_remote_rake(rake_cmd)
  rake_args = ENV['RAKE_ARGS'].to_s.split(',')
  cmd = "cd #{fetch(:latest_release)} && #{fetch(:rake, "rake")} RAILS_ENV=#{fetch(:rails_env, "production")} #{rake_cmd}"
  cmd += "['#{rake_args.join("','")}']" unless rake_args.empty?
  run cmd
  set :rakefile, nil if exists?(:rakefile)
end