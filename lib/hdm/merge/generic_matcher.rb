# frozen_string_literal: true

module HDM
  module Merge
    class GenericMatcher
      def self.match(_resource, _profile)
        []
      end

      def self.deconflict(_resource, _matches)
        []
      end
    end
  end
end
