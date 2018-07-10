# frozen_string_literal: true

require 'rake'

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

  desc 'Manually Trigger Profile Sync'
  task :sync_profile, [:profile_provider_id] => :environment do |_t, args|
    pp = ProfileProvider.find(args.profile_provider_id)

    client = HDM::Client.get_client(pp.provider)
    client.sync_profile(pp)

    DataReceipt.where(profile: pp.profile).each(&:process!)
    HDM::Merge:: Merger.new.update_profile(pp.profile)
  end
end
