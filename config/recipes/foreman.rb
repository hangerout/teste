namespace :foreman do
  desc 'Export the Procfile to linux upstart scripts'
  task :export, :roles => :app do
    run "cd #{release_path} && sudo bundle exec foreman export upstart /etc/init -a #{application} -u #{user} -l #{release_path}/log/foreman"
  end
  after "deploy:update", "foreman:export"    # Export foreman scripts
  #after "deploy:symlink", "foreman:export"

  %w[start stop restart].each do |command|
    desc "#{command} the app server"
    task command, roles: :app do
      run "service #{application} #{command}"
    end
    after "deploy:#{command}", "foreman:#{command}"
  end
end