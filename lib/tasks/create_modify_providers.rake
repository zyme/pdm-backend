# frozen_string_literal: true

require 'rake'
require 'json'

namespace :create_modify_providers do
  desc 'Adding providers if they do not exist or modifying them overall'
  task :add_provider, %i[file] => :environment do |_t, args|
    all_providers = File.open(args.file, 'r:UTF-8').read
    all_providers.each_line do |provider|
      provider_hash = JSON.parse(provider)
      provider_hash["provider_type"] = "smart"
      #ßputs provider_hash['name']
      puts Provider.where(name: "FitBit").take
      if Provider.where(name: provider_hash['name']).take.nil?
        new_provider = Provider.create(provider_hash)
        if new_provider.validate
          puts "Added new provider #{provider_hash["name"]}"
        else
          puts "Error when trying to add provider #{provider_hash["name"]}"
        end
      else
        updates = Provider.update(provider_hash)
      end
    end
  end
end
