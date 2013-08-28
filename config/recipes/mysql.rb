set_default(:mysql_host, "localhost")
set_default(:mysql_user) { application[0..15] }
set_default(:mysql_root_password) { Capistrano::CLI.password_prompt "MySQL root password: " }
set_default(:mysql_password) { Capistrano::CLI.password_prompt "MySQL #{mysql_user} Password: " }
set_default(:mysql_database) { "#{application}_production" }

namespace :mysql do
  desc "Install the latest stable release of MySQL."
  task :install, :roles => :db, :only => {:primary => true} do
    run "#{sudo} apt-get -y install mysql-server" do |channel, stream, data|
      # prompts for mysql root password (when blue screen appears)
      channel.send_data("#{mysql_root_password}\n\r") if data =~ /password/
    end
  end
  after "deploy:install", "mysql:install"

  desc "Create a database for this application."
  task :create_database, :roles => :db, :only => {:primary => true} do
    run "mysql --user='root' --password='#{mysql_root_password}' --execute='create database if not exists #{mysql_database};'"
    run %Q{mysql --user='root' --password='#{mysql_root_password}' --execute="grant all on #{mysql_database}.* to #{mysql_user}@localhost identified by '#{mysql_password}';"}
  end
  after "deploy:setup", "mysql:create_database"

  desc "Generate the database.yml configuration file."
  task :setup, :roles => :app do
    run "mkdir -p #{shared_path}/config"
    template "mysql.yml.erb", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "mysql:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "mysql:symlink"
end