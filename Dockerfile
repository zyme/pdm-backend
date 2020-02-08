FROM ruby:2.6.3

# see update.sh for why all "apt-get install"s have to stay as one long line
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

# see http://guides.rubyonrails.org/command_line.html#rails-dbconsole
RUN apt-get update && apt-get install -y mysql-client postgresql-client sqlite3 nano --no-install-recommends && rm -rf /var/lib/apt/lists/*

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

# override this please
ENV SECRET_KEY_BASE=not-so-great

# todo arz env vars coming in through compose file
ENV DB_HOST=postgres
ENV DB_USER=postgres
ENV DB_PASSWORD=test

# Expose port 3000 from the container

RUN gem install bundler
RUN bundle install

# Run puma server by default
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
EXPOSE 3000
