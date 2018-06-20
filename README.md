# Health Data Manager - Backend Server

## About

This project is the backend for the Health Data Manager.


## Quick Start

### System Requirements

 - Ruby, v2.3.5 or higher ([rvm](https://rvm.io/) is recommended for managing multiple versions of Ruby)
 - PostgreSQL, v9.4 or higher, running on port 5432

### Installation
```
gem install bundler
bundle install
bundle exec rake db:setup

# finally, to confirm it worked -- should see "<#> runs, <#> assertions, 0 failures, 0 errors, 0 skips" at the end
bundle exec rake test
```

### Usage
```
bundle exec rails s
```

To optionally specify port: (default is 3000 if not specified)

```
bundle exec rails s --port 7001
```

To execute the test suite:

```
bundle exec rake test
```

# License
Copyright 2018 The MITRE Corporation 
