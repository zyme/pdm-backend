# frozen_string_literal: true

module HDM
  module OAuth
    module State
      def self.encode(provider_id, profile_id, extra = {})
        data = { provider_id: provider_id,
                 profile_id: profile_id }.merge(extra)
        Base64.encode64(data.to_json)
      end

      def self.decode(state)
        data = Base64.decode64(state)
        json = JSON.parse(data)
      end
    end
  end
end
