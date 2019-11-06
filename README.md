# Patient Data Manager - Backend Server

## About

This project is the backend for the Patient Data Manager.

## Quick Start

### System Requirements

 - Ruby, v2.3.5 or higher ([rvm](https://rvm.io/) is recommended for managing multiple versions of Ruby)
 - PostgreSQL, v9.4 or higher, running on port 5432

### Installation
```sh
gem install bundler
bundle install
bundle exec rake db:setup

# finally, to confirm it worked -- should see "<#> runs, <#> assertions, 0 failures, 0 errors, 0 skips" at the end
bundle exec rake test
```

### Usage
```sh
bundle exec rails s
```

To optionally specify port: (default is 3000 if not specified)

```sh
bundle exec rails s --port 7001
```

To execute the test suite:

```sh
bundle exec rake test
```

### Configuring the front end

At present, the CORS headers required to run the front end on a different server are commented out. If the front end is running on a different web server, you will need to add back in the `Rack::Cors` middleware in `config/application.rb` before it will work.

# License
Copyright 2018, 2019 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.