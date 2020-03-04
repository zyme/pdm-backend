#!/bin/bash
cd /usr/src
echo "Installing..."
gem install bundler
bundle install
echo "Running migrations"
rake db:create
rake db:migrate
echo "Starting server"
rails server -b 0.0.0.0
#bundle exec puma -C config/puma