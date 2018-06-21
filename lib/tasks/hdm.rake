# frozen_string_literal: true

require 'rake'

namespace :hdm do
  desc 'Manual Import of FHIR resources'
  task :manual_import, %i[profile_id provider_id file] => :environment do |_t, args|
    bundle_json = File.open(args.file, 'r:UTF-8').read

    receipt = DataReceipt.new(profile_id: args.profile_id,
                              provider_id: args.provider_id,
                              data_type: 'fhir_bundle',
                              data: bundle_json)

    receipt.process!
  end
end
