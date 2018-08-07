# frozen_string_literal: true

require 'rake'

namespace :provider_client do
  desc 'Simulate Posting Encounter Data Receipt'
  task :post_edr, %i[file base_url] => :environment do |_t, args|
    args.with_defaults(base_url: 'https://localhost:3000')

    bundle_json = File.open(args.file, 'r:UTF-8').read

    users = User.all.to_a

    user_indx = 0
    profile_indx = 0
    provider_indx = 0

    if users.empty?
      puts 'There are no users in the system, please add a user before continuing'
      return
    elsif users.length > 1
      puts 'Select which user you want to load the data for '
      users.each_with_index { |u, i| puts "#{i}. #{u.email}" }
      user_indx = STDIN.gets.chomp.to_i
    else
      puts "Using only user in the system: #{users[user_indx].email}"
    end

    user = users[user_indx]
    profiles = user.profiles
    if profiles.empty?
      puts 'User has no profile, please create a profile before continuing'
      return
    elsif profiles.length > 1
      puts 'Select which profile you want to load the data into '
      profiles.each_with_index { |p, i| puts "#{i}. #{p.name}" }
      profile_indx = STDIN.gets.chomp.to_i
    else
      puts "User only has a single profile, using profile #{profiles[profile_indx.to_i].name}"
    end
    profile = profiles[profile_indx.to_i]

    providers = Provider.all.to_a.find_all { |p| ProviderApplication.exists?(provider: p) }
    if providers.empty?
      puts 'There are no providers with applications in the system, please load some providers before continuing'
    elsif providers.length > 1
      puts 'Select which provider you want to associate the EDR with:'
      providers.each_with_index { |p, i| puts "#{i} #{p.name}" }
      puts '(Note: other providers may exist but do not have applications setup.'
      puts ' Run the hdm:create_provider_application rake task to create the application)'
      provider_indx = STDIN.gets.chomp.to_i
    else
      puts "There is only 1 provider with an application in the system, using provider #{providers[provider_indx.to_i].name}"
    end
    provider = providers[provider_indx.to_i]

    # inject the profile ID into the bundle.
    # nearly the same logic as extracting the id in BaseController
    bundle = FHIR::Json.from_json(bundle_json)
    patient = bundle.entry.find { |e| e.resource.resourceType == 'Patient' }.resource
    ids = patient.identifier
    ident = ids.find { |id| id.system == 'urn:health_data_manager:profile_id' }
    if ident
      puts 'Found HDM profile_id identifier. Overwriting value to selected profile.id'
      ident.value = profile.id
    else
      puts 'Injecting profile_id into patient identifier list'
      ids << FHIR::Identifier.new(system: 'urn:health_data_manager:profile_id', value: profile.id)
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

    uri = URI("#{base_url}/api/v1/")
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
