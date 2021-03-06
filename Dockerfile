FROM ruby:2.3.5

# see update.sh for why all "apt-get install"s have to stay as one long line
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

# see http://guides.rubyonrails.org/command_line.html#rails-dbconsole
RUN apt-get update && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Bundle into the temp directory
WORKDIR /tmp
ADD Gemfile* ./


# Copy the app's code into the container
ENV APP_HOME /app
COPY . $APP_HOME
WORKDIR $APP_HOME

# Configure production environment variables
ENV RAILS_ENV=production \
    RACK_ENV=production

# Expose port 3000 from the container

RUN gem install bundler
RUN bundle install
# Run puma server by default
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
EXPOSE 3000
