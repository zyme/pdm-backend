# frozen_string_literal: true

require 'rake'
require 'json'

def display_error_msg(current_provider)
  error_msg = ''
  if current_provider.errors.nil?
    error_msg = 'Unknown Error'
  else
    current_provider.errors.messages.each do |k, v|
      v.each do |msg|
        error_msg += "#{k} #{msg}\n"
      end
    end
  end
  puts "Error! Could not add/update provider #{current_provider['name']}. Exited with message(s): #{error_msg}"
end

namespace :provider do
  desc 'Adding providers if they do not exist or modifying them overall'
  task :load, %i[file] => :environment do |_t, args|
    all_providers = JSON.parse(File.open(args.file, 'r:UTF-8').read)['Entries']
    all_providers.each do |each_provider|
      specific_provider = Provider.where(name: each_provider['name']).take
      if specific_provider.nil?
        new_provider = Provider.create(each_provider)
        save_success = new_provider.save
        if save_success
          puts "Added new provider #{each_provider['name']}"
        else
          display_error_msg(new_provider)
        end
      else
        specific_provider.update(each_provider)
        if specific_provider.save
          puts "Updated the provider #{each_provider['name']}."
        else
          display_error_msg(specific_provider)
        end
      end
    end
  end
end