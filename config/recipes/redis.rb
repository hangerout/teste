namespace :redis do
  # Install redis from apt repository ppa
  #desc "Install latest stable release of redis"
  #task :install, :roles => :web do
  #  run "#{sudo} add-apt-repository ppa:rwky/redis", :pty => true do |ch, stream, data|
  #    press_enter(ch, stream, data)
  #  end
  #  run "#{sudo} apt-get -y update"
  #  run "#{sudo} apt-get -y install redis-server"
  #end
  #after "deploy:install", "redis:install"

  desc "Install latest stable release of redis"
  task :install, :roles => :web do
    [
        "wget http://download.redis.io/redis-stable.tar.gz",
        "tar xvzf redis-stable.tar.gz",
        "cd redis-stable/ && make"
    ].each {|cmd| run cmd}

  end
  after "deploy:install", "redis:install"

  desc "Setup redis configuration for this application"
  task :setup, :roles => :app do

    # Copy redis-server and redis-cli executables
    # Run just once, after conflict
    run "#{sudo} cp /home/#{user}/redis-stable/src/redis-server /usr/local/bin"
    run "#{sudo} cp /home/#{user}/redis-stable/src/redis-cli /usr/local/bin"

    #run "#{sudo} cp /usr/bin/redis-server /usr/local/bin"
    #run "#{sudo} cp /usr/bin/redis-cli /usr/local/bin"

    # Create a directory where to store your Redis config files and your data:
    run "#{sudo} mkdir -p /etc/redis"
    run "#{sudo} mkdir -p /var/redis"
    run "#{sudo} chmod -R 777 /var/redis"

    # Create a directory where to store data
    run "#{sudo} mkdir -p /var/redis/6379"

    # Make a writable log file
    run "#{sudo} touch /var/log/redis_6379.log"
    run "#{sudo} chown #{user} /var/log/redis_6379.log"
    run "#{sudo} chmod u+w /var/log/redis_6379.log"

    # Make an config file
    template "redis_conf.erb", "/tmp/6379.conf"
    run "#{sudo} mv /tmp/6379.conf /etc/redis/6379.conf"
    #run "#{sudo} chown #{user}:redis_6379 -R /etc/redis/"

    # Make an init script
    template "redis_init_script.erb", "/tmp/redis_6379"
    run "#{sudo} mv /tmp/redis_6379 /etc/init.d/redis_6379"
    run "chmod u+x /etc/init.d/redis_6379"
    run "#{sudo} update-rc.d -f redis_6379 defaults"

    # Start redis
    run "/etc/init.d/redis_6379 start"
  end
  after "deploy:setup", "redis:setup"

  %w[start stop].each do |command|
    desc "#{command} redis-server"
    task command, :roles => :web do
      run "#{sudo} service redis-server #{command}"
    end
  end
end

def press_enter( ch, stream, data)
  if data =~ /Press.\[ENTER\].to.continue/
    # prompt, and then send the response to the remote process
    ch.send_data( "\n")
  else
    # use the default handler for all other text
    Capistrano::Configuration.default_io_proc.call( ch, stream, data)
  end
end