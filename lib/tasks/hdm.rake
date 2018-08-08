# frozen_string_literal: true

require 'rake'
require 'json'

namespace :hdm do
  desc 'Manual Import of FHIR resources'
  task :import_fhir, %i[profile_id provider_id file] => :environment do |_t, args|
    bundle_json = File.open(args.file, 'r:UTF-8').read

    receipt = DataReceipt.new(profile_id: args.profile_id,
                              provider_id: args.provider_id,
                              data_type: 'fhir_bundle',
                              data: bundle_json)

    receipt.process!
    merger = HDM::Merge:: Merger.new
    merger.update_profile(receipt.profile)
  end

  desc 'Manual Import of FHIR resources'
  task :load, %i[file create_user account_email account_password] => :environment do |_t, args|
    bundle_json = File.open(args.file, 'r:UTF-8').read
    json_format = JSON.parse(bundle_json)
    user_indx = 0
    if args.create_user == 'y'
      patient_entry = json_format['entry'].find \
       { |eachentry| eachentry.key?('resource') && eachentry['resource'].key?('resourceType') && eachentry['resource']['resourceType'] == 'Patient' }
      user_first_name = patient_entry['resource']['name'][0]['given'][0]
      user_last_name = patient_entry['resource']['name'][0]['family']
      user_email = args.account_email || user_first_name + '_' + user_last_name[0] + '@test.com'
      user_password = args.account_password || 'Password123'
      created = User.create(first_name: user_first_name, last_name: user_last_name, email: user_email, password: user_password)
      if !created.validate
        puts 'Could not create a new user with given bundle'
        error_msg = ''
        if created.errors.nil?
          error_msg = 'Unknown Error'
        else
          created.errors.messages.each do |k, v|
            v.each do |msg|
              error_msg += "#{k} #{msg}\n"
            end
          end
          puts "Exited with message(s): #{error_msg}"
          exit(0)
        end
      else
        puts "Created account for #{user_first_name} #{user_last_name} with email #{user_email} and password #{user_password}"
        user_indx = -1
      end
    else
      users = User.all.to_a
      if users.empty?
        puts 'There are no users in the system, please add a user before continuing'
        exit(0)
      elsif users.length > 1
        puts 'Select which user you want to load the data for '
        users.each_with_index { |u, i| puts "#{i}. #{u.email}" }
        user_indx = STDIN.gets.chomp.to_i
      else
        puts "Using only user in the system: #{users[user_indx].email}"
      end
    end

    users = User.all.to_a
    user = users[user_indx]
    providers = Provider.all.to_a
    profile_indx = 0
    provider_indx = 0
    profiles = user.profiles
    if profiles.empty?
      puts 'User has no profile, please create a profile before continuing'
      exit(0)
    elsif profiles.length > 1
      puts 'Select which profile you want to load the data into '
      profiles.each_with_index { |p, i| puts "#{i}. #{p.name}" }
      profile_indx = STDIN.gets.chomp.to_i
    else
      puts "User only has a single profile, using profile #{profiles[profile_indx.to_i].name}"
    end

    if providers.empty?
      puts 'There are no providers in the system, please load some providers before continuing'
      exit(0)
    elsif providers.length > 1
      puts 'Select which provider you want to assocaiate the data with '
      providers.each_with_index { |p, i| puts "#{i} #{p.name}" }
      provider_indx = STDIN.gets.chomp.to_i
    else
      puts "There is only 1 provider in the system, using provider #{providers[provider_indx.to_i].name}"
    end
    profile = profiles[profile_indx.to_i]
    provider = providers[provider_indx.to_i]

    receipt = DataReceipt.new(profile_id: profile.id,
                              provider_id: provider.id,
                              data_type: 'fhir_bundle',
                              data: bundle_json)

    receipt.process!
    merger = HDM::Merge:: Merger.new
    merger.update_profile(receipt.profile)

    # select a profile
  end

  desc 'Manually Trigger Profile Sync'
  task :sync_profile, [:profile_provider_id] => :environment do |_t, args|
    pp = ProfileProvider.find(args.profile_provider_id)

    client = HDM::Client.get_client(pp.provider)
    client.sync_profile(pp)

    DataReceipt.where(profile: pp.profile).each(&:process!)
    HDM::Merge:: Merger.new.update_profile(pp.profile)
  end
end
