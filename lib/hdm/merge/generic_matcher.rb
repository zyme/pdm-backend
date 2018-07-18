# frozen_string_literal: true

module HDM
  module Merge
    class GenericMatcher
      MATCH_THRESHOLD = 0.8
      NON_COMPARABLE_PATHS = %w[url system id _id text reference resourcetype].freeze
      FLOAT_TOLERANCE = 0.0001
      DATETIME_REGEX = Regexp.new(FHIR::PRIMITIVES['dateTime']['regex']).freeze

      def self.match(resource, relationship)
        potential_matches = relationship.map { |r| score_match(resource, r.resource) }
        potential_matches.find_all { |pm| pm[:score] >= MATCH_THRESHOLD }
      end

      def self.deconflict(resource, matches)
        # resource: new incoming resource
        # matches: existing resources that match with some %
        []
      end

      def self.score_match(left, right)
        left_path_maps = traverse(to_hash(left))

        right_path_maps = traverse(to_hash(right))

        { left: left, right: right,
          score: score_paths(left_path_maps, right_path_maps) }
      end

      def self.to_hash(obj)
        case obj
        when FHIR::Model
          obj.to_hash
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

      def self.score_paths(left_path_maps, right_path_maps)
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
        match_count.to_f / matchable_paths.length
      end

      def self.strip_unsuitable_paths(paths)
        paths.reject { |p| NON_COMPARABLE_PATHS.any? { |ncp| p.downcase.include?(ncp) } }
      end

      def self.values_match?(left, right)
        case left
        when String
          strings_match?(left, right)
        when Float
          floats_match(left, right)
        else
          # TODO: any other special handling needed here?
          left == right
        end
      end

      def self.strings_match?(left, right)
        # special handling for date-times
        if DATETIME_REGEX.match?(left) && DATETIME_REGEX.match?(right)
          left_date = Time.iso8601(left)
          right_date = Time.iso8601(right)
          return dates_match?(left_date, right_date)
        end

        # just use regular string equality
        left == right
      end

      def self.dates_match?(left, right)
        # per pt merge, we consider DateTimes equal if they fall on the same day
        left = left.utc
        right = right.utc

        left.year == right.year && left.month == right.month && left.day == right.day
      end

      def self.floats_match(left, right)
        (left - right).abs < FLOAT_TOLERANCE
      end
    end
  end
end
