# frozen_string_literal: true

require 'rake'
require 'json'
require_relative 'selection_functions'

namespace :hdm do
  include SelectionFunctions
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
  task :load, %i[file create_user_account account_email account_password] => :environment do |_t, args|
    bundle_json = File.open(args.file, 'r:UTF-8').read
    json_format = JSON.parse(bundle_json)
    user = if args.create_user_account == 'y'
             SelectionFunctions.create_user(json_format, args.account_email, args.account_password)
           else
             SelectionFunctions.select_user
           end
    exit(0) if user.nil?
    profile = SelectionFunctions.select_profile(user)
    exit(0) if profile.nil?
    provider = SelectionFunctions.select_provider
    exit(0) if provider.nil?

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

  desc 'Create Doorkeeper Application for Provider'
  task :create_provider_application, [] => :environment do |_t, _args|
    provider = SelectionFunctions.select_provider

    pa = ProviderApplication.find_by(provider: provider)

    if pa
      app = pa.application
      puts 'Found existing application for provider: '
    else
      app = Doorkeeper::Application.create(name: provider.name, redirect_uri: 'http://example.com')
      ProviderApplication.create(provider_id: provider.id, application_id: app.id)
      puts 'Created successfully.'
    end

    puts app.inspect
    puts "Client ID: #{app.uid}"
    puts "Client Secret: #{app.secret}"
  end
end
