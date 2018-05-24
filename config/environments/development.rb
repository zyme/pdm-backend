Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # # Raise an error on page load if there are pending migrations.
  # config.active_record.migration_error = :page_load
  #
  # # Highlight code that triggered database queries in logs.
  # config.active_record.verbose_query_logs = true
  #

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker


  # Allowed options: :sql, :ruby.
    config.sequel.schema_format = :sql

    # Whether to dump the schema after successful migrations.
    # Defaults to false in production and test, true otherwise.
    config.sequel.schema_dump = true

    # These override corresponding settings from the database config.
    config.sequel.max_connections = 16
    config.sequel.search_path = %w(mine public)

    # Configure whether database's rake tasks will be loaded or not.
    #
    # If passed a String or Symbol, this will replace the `db:` namespace for
    # the database's Rake tasks.
    #
    config.sequel.load_database_tasks = :sequel
    #     will results in `rake db:migrate` to become `rake sequel:migrate`
    #
    # Defaults to true
    # config.sequel.load_database_tasks = :sequel

    # This setting disabled the automatic connect after Rails init
    # config.sequel.skip_connect = false 
    #
    # # If you want to use a specific logger
    # config.sequel.logger = MyLogger.new($stdout)
end
