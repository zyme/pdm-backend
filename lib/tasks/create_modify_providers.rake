# frozen_string_literal: true

require 'rake'
require 'json'

namespace :create_modify_providers do
  desc 'Adding providers if they do not exist or modifying them overall'
  task :add_provider, %i[file] => :environment do |_t, args|
    all_providers = File.open(args.file, 'r:UTF-8').read
    all_providers.each_line do |provider|
      provider_hash = JSON.parse(provider)
      provider_hash['provider_type'] = 'smart'
      specific_provider = Provider.where(name: provider_hash['name']).take
      if specific_provider.nil?
        new_provider = Provider.create(provider_hash)

        if new_provider.validate
          puts "Added new provider #{provider_hash['name']}"
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
          puts "Error! Could not add provider #{provider_hash[name]}. Exited with message(s): #{error_msg}"
        end
      else
        result = specific_provider.update(provider_hash)
        if result
          puts "Updated the provider #{provider_hash['name']}."
        else
          puts "Could not update the provider #{provider_hash['name']}."
        end
      end
    end
  end
end
