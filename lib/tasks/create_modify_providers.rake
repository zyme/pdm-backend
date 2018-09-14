# frozen_string_literal: true

require 'rake'
require 'json'

namespace :provider do
  desc 'Adding providers if they do not exist or modifying them overall'
  task :load, %i[file] => :environment do |_t, args|
    all_providers = JSON.parse(File.open(args.file, 'r:UTF-8').read)['Entries']
    all_providers.each do |each_provider|
      specific_provider = Provider.where(name: each_provider['name']).take
      each_provider['provider_type'] = 'smart_epic'
      if specific_provider.nil?
        new_provider = Provider.create(each_provider)
        save_success = new_provider.save
        if save_success
          puts "Added new provider #{each_provider['name']}"
        else
          error_msg = ''
          if new_provider.errors.nil?
            error_msg = 'Unknown Error'
          else
            new_provider.errors.messages.each do |k, v|
              v.each do |msg|
                error_msg += "#{k} #{msg}\n"
              end
            end
          end
          puts "Error! Could not add provider #{each_provider[name]}. Exited with message(s): #{error_msg}"
        end
      else
        result = specific_provider.update(each_provider)
        if result
          puts "Updated the provider #{each_provider['name']}."
        else
          error_msg = ''
          if specific_provider.errors.nil?
            error_msg = 'Unknown Error'
          else
            specific_provider.errors.messages.each do |k, v|
              v.each do |msg|
                error_msg += "#{k} #{msg}\n"
              end
            end
          end
          puts "Could not update the provider #{each_provider['name']}."
        end
      end
    end
  end
end
