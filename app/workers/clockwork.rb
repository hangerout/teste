require './config/boot'
require './config/environment'
require 'clockwork'
include Clockwork

handler do |job|
  puts "Running #{job}"
end

every 10.seconds, 'Testing clock work' do
  puts "Clock Work OK!"
end