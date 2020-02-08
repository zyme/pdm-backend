# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Create the self provider in the seeds
Provider.create! provider_type: 'self', name: 'Self Reported', description: 'Records sent via a patient themselves', base_endpoint: 'https://localhost/'
# Hack alert, put in broad epic creds
Provider.create! provider_type: "smart_epic", name: "Atrius Health", base_endpoint: "https://iatrius.atriushealth.org/FHIR/api/FHIR/DSTU2/"
