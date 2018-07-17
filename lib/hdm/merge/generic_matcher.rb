# frozen_string_literal: true

module HDM
  module Merge
    class GenericMatcher
      MATCH_THRESHOLD = 0.8
      NON_COMPARABLE_PATHS = %w[url system id _id text reference resourcetype].freeze

      def self.match(resource, relationship)
        relationship.find_all { |r| match?(resource, r.resource) }
      end

      def self.deconflict(_resource, _matches)
        []
      end

      def self.match?(lhs, rhs)
        left_path_maps = traverse(to_hash(lhs))

        right_path_maps = traverse(to_hash(rhs))

        paths_match?(left_path_maps, right_path_maps)
      end

      def self.to_hash(obj)
        case obj
        when FHIR::Model
          JSON.parse(obj.to_s)
        when String
          JSON.parse(obj)
        else
          obj
        end
      end

      def self.traverse(obj, path_map = {}, path = '')
        prefix = path == '' ? '' : path + '.'

        case obj
        when Hash
          obj.each { |k, v| traverse(v, path_map, prefix + k.to_s) }
        when Array
          # TODO: IMPORTANT -- this compares array contents by index
          # meaning 2 arrays with equivalent contents but different order
          # will not match. we should review
          obj.each_with_index { |v, i| traverse(v, path_map, prefix + i.to_s) }
        else
          path_map[path] = obj
        end

        path_map
      end

      def self.paths_match?(left_path_maps, right_path_maps)
        # we can only match on paths in both resources
        common_paths = left_path_maps.keys & right_path_maps.keys

        # But don't match on every path - some are unsuitable for matching.
        matchable_paths = strip_unsuitable_paths(common_paths)

        # There is nothing in common to match on.
        return false unless matchable_paths.any?

        match_count = matchable_paths.count { |p| values_match?(left_path_maps[p], right_path_maps[p]) }

        # Test how many of the common paths were a match. If the percentage of matches exceeds
        # the configurable MatchThreshold, we've got a match. At this point matchable_paths is
        # guaranteed not to be empty, making division by 0 impossible.
        (match_count / matchable_paths.length) >= MATCH_THRESHOLD
      end

      def self.strip_unsuitable_paths(paths)
        paths.reject { |p| NON_COMPARABLE_PATHS.any? { |ncp| p.downcase.include?(ncp) } }
      end

      def self.values_match?(left_value, right_value)
        # TODO: any special handling needed here? doubles? dates?
        left_value == right_value
      end
    end
  end
end
