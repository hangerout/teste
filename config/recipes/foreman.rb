set_default(:procfile, "Procfile")

namespace :foreman do
  desc 'Export the Procfile to linux upstart scripts'
  task :export, :roles => :app do
    foreman = "foreman export upstart /etc/init -a #{application} \
                 -l #{shared_path}/log -u #{user} -d #{current_path} \
                 -f #{current_path}/#{procfile}"

    run "cd #{current_path} && #{sudo} #{foreman}"
  end
  after "deploy:update", "foreman:export"    # Export foreman scripts
  #after "deploy:symlink", "foreman:export"

  %w[start stop restart].each do |command|
    desc "#{command} the app server"
    task command, roles: :app do
      run "service foreman #{command}"
    end
    after "deploy:#{command}", "foreman:#{command}"
  end
end