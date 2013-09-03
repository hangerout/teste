source 'https://rubygems.org'

gem 'rails', '3.2.14'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

group :deploy do
  gem 'capistrano'
  gem 'rvm-capistrano'
end

group :production do
  gem 'unicorn'
end

# To use debugger
# gem 'debugger'

#Background process
gem 'sidekiq', '~> 2.13.0'

gem 'sinatra', '~> 1.4.3'

gem 'slim', '~> 2.0.1'

# Process management
gem 'foreman'

#Schedule workers
gem "clockwork", "~> 0.6.0"

gem "daemons", "~> 1.1.9"