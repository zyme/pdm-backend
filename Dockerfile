FROM ruby:2.6.3

# see update.sh for why all "apt-get install"s have to stay as one long line
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

# see http://guides.rubyonrails.org/command_line.html#rails-dbconsole
RUN apt-get update && apt-get install -y mysql-client postgresql-client sqlite3 nano --no-install-recommends && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

# Configure production environment variables
ENV RAILS_ENV=production \
    RACK_ENV=production