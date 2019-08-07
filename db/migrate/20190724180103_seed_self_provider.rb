# frozen_string_literal: true

class SeedSelfProvider < ActiveRecord::Migration[5.2]
  # Stub model to prevent future updates from breaking this migration
  class Provider < ApplicationRecord
    belongs_to :parent, foreign_key: :parent_id, class_name: 'Provider', optional: true
  end

  def change
    reversible do |dir|
      dir.up do
        # Simply create the new self provider.
        Provider.create! provider_type: 'self', name: 'Self Reported', description: 'Records sent via a patient themselves', base_endpoint: 'https://localhost/'
      end
      dir.down do
        Provider.where(provider_type: 'self').destroy
      end
    end
  end
end
