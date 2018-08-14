# frozen_string_literal: true

module HDM
  module Client
    class EpicSmartClient < SmartClient
      def supported_resource_types
        super - [FHIR::DSTU2::Observation]
      end
    end
  end
end
