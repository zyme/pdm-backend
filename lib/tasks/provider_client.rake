# frozen_string_literal: true

require 'rake'
require_relative 'selection_functions'

namespace :provider_client do
  include SelectionFunctions
  desc 'Simulate Posting Encounter Data Receipt'
  task :post_edr, %i[file base_url] => :environment do |_t, args|
    args.with_defaults(base_url: 'https://localhost:3000')

    bundle_json = File.open(args.file, 'r:UTF-8').read

    user = SelectionFunctions.select_user
    exit(0) if user.nil?
    profile = select_profile(user)
    exit(0) if profile.nil?
    provider = select_provider_client
    exit(0) if provider.nil?

    bundle = FHIR::Json.from_json(bundle_json)
    bundle.type = 'message'

    patient = bundle.entry.find { |e| e.resource.resourceType == 'Patient' }.resource

    # inject a MessageHeader resource into the bundle
    # for FHIR Messaging the MessageHeader must be the first entry
    message_header = bundle.entry.first.resource
    if message_header.resourceType == 'MessageHeader'
      puts 'MessageHeader already exists in bundle, not creating a new one'
      # inject the profile ID into the bundle.
      # nearly the same logic as extracting the id in BaseController
      puts 'Updating Parameters with selected profile id'
      params = bundle.entry.find { |e| e.resource.resourceType == 'Parameters' }.resource
      params.parameter.find { |p| p.name == 'health_data_manager_profile_id' }.valueString = profile.id.to_s
    else
      puts 'Creating MessageHeader entry in bundle'

      encounter = bundle.entry.first { |e| e.resource.resourceType == 'Encounter' }.resource

      parameters = { 'resourceType' => 'Parameters',
                     'id' => SecureRandom.uuid,
                     'parameter' => [{ 'name' => 'health_data_manager_profile_id', 'valueString' => profile.id.to_s }] }

      entry = FHIR::Bundle::Entry.new('resource' => parameters, 'fullUrl' => "urn:uuid:#{parameters['id']}")
      bundle.entry.insert(0, entry)

      message_header = { 'resourceType' => 'MessageHeader',
                         'timestamp' => Time.now.iso8601,
                         'event' => { 'system' => 'urn:health_data_manager', 'code' => 'EDR', 'display' => 'Encounter Data Receipt' },
                         'source' => { 'name' => provider.name, 'endpoint' => provider.base_endpoint },
                         'focus' => [{ 'reference' => "urn:uuid:#{parameters['id']}" },
                                     { 'reference' => "urn:uuid:#{encounter.id}" },
                                     { 'reference' => "urn:uuid:#{patient.id}" }] }
      entry = FHIR::Bundle::Entry.new('resource' => message_header)
      bundle.entry.insert(0, entry)
    end

    bundle_json = bundle.to_json

    # get the provider client_id and client_secret to get the token
    pa = ProviderApplication.find_by(provider: provider)
    app = pa.application
    client_id = app.uid
    client_secret = app.secret

    base_url = args.base_url

    uri = URI("#{base_url}/oauth/token")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = "grant_type=client_credentials&client_id=#{client_id}&client_secret=#{client_secret}"

    response = http.request(request)

    token = JSON.parse(response.body)['access_token']

    uri = URI("#{base_url}/api/v1/$process-message")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request['Authorization'] = "Bearer #{token}"
    request['Content-Type'] = 'application/json'
    request.body = bundle_json

    response = http.request(request)

    # TODO: maybe more error handling?
    puts response.message
  end
end
