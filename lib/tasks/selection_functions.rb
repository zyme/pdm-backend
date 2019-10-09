# frozen_string_literal: true

module SelectionFunctions
  def select_user
    users = User.all.to_a
    user_indx = 0
    if users.empty?
      puts 'There are no users in the system, please add a user before continuing'
      return nil
    elsif users.length > 1
      puts 'Select which user you want to load the data for '
      users.each_with_index { |u, i| puts "#{i}. #{u.email}" }
      user_indx = STDIN.gets.chomp.to_i
    else
      puts "Using only user in the system: #{users[user_indx].email}"
    end
    users[user_indx]
  end

  def create_user(json_format, email, password)
    patient_entry = json_format['entry'].find \
     { |eachentry| eachentry.key?('resource') && eachentry['resource'].key?('resourceType') && eachentry['resource']['resourceType'] == 'Patient' }
    user_first_name = patient_entry['resource']['name'][0]['given'][0]
    user_last_name = patient_entry['resource']['name'][0]['family']
    user_email = email
    user_password = password
    user = User.create(first_name: user_first_name, last_name: user_last_name, email: user_email, password: user_password)
    unless user.validate
      puts 'Could not create a new user with given bundle'
      error_msg = ''
      if user.errors.nil?
        error_msg = 'Unknown Error'
      else
        user.errors.messages.each do |k, v|
          v.each do |msg|
            error_msg += "#{k} #{msg}\n"
          end
        end
        puts "Exited with message(s): #{error_msg}"
        return nil
      end
    end
    puts "Created account for #{user_first_name} #{user_last_name} with email #{user_email}"
    user
  end

  def select_profile(user)
    profiles = user.profiles
    profile_indx = 0
    if profiles.empty?
      puts 'User has no profile, please create a profile before continuing'
      return nil
    elsif profiles.length > 1
      puts 'Select which profile you want to load the data into '
      profiles.each_with_index { |p, i| puts "#{i}. #{p.name}" }
      profile_indx = STDIN.gets.chomp.to_i
    else
      puts "User only has a single profile, using profile #{profiles[profile_indx.to_i].name}"
    end
    profiles[profile_indx]
  end

  def select_provider
    providers = Provider.all.to_a
    provider_indx = 0
    if providers.empty?
      puts 'There are no providers in the system, please load some providers before continuing'
      return nil
    elsif providers.length > 1
      puts 'Select which provider you want to assocaiate the data with '
      providers.each_with_index { |p, i| puts "#{i} #{p.name}" }
      provider_indx = STDIN.gets.chomp.to_i
    else
      puts "There is only 1 provider in the system, using provider #{providers[provider_indx.to_i].name}"
    end
    providers[provider_indx]
  end

  def select_provider_client
    provider_indx = 0
    providers = Provider.all.to_a.find_all { |p| ProviderApplication.exists?(provider: p) }
    if providers.empty?
      puts 'There are no providers with applications in the system, please load some providers before continuing'
      return nil
    elsif providers.length > 1
      puts 'Select which provider you want to associate the EDR with:'
      providers.each_with_index { |p, i| puts "#{i} #{p.name}" }
      puts '(Note: other providers may exist but do not have applications setup.'
      puts ' Run the hdm:create_provider_application rake task to create the application)'
      provider_indx = STDIN.gets.chomp.to_i
    else
      puts "There is only 1 provider with an application in the system, using provider #{providers[provider_indx.to_i].name}"
    end
    providers[provider_indx.to_i]
  end
end
