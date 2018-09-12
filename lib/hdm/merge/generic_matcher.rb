# frozen_string_literal: true

module HDM
  module Merge
    class GenericMatcher
      MATCH_THRESHOLD = 0.8
      NON_COMPARABLE_PATHS = %w[url system id _id text reference resourcetype meta].freeze
      FLOAT_TOLERANCE = 0.0001
      DATETIME_REGEX = Regexp.new(FHIR::PRIMITIVES['dateTime']['regex']).freeze

      # the set of fields for which a match on this field is required to be a match overall
      # for starters we just use dates, i.e., if 2 objects have different dates they necessarily do not match
      REQUIRED_FIELDS = %w[onsetDateTime effectiveDateTime authoredOn date].freeze

      def self.match(resource, relationship)
        # resource: new incoming resource
        # relationship: existing list of resources to compare against

        # note that ptmerge returns the first match found, rather than all matches
        potential_matches = relationship.map { |r| score_match(resource, r.fhir_model) }
        potential_matches.find { |pm| pm[:score] && pm[:score] >= MATCH_THRESHOLD }
      end

      def self.deconflict(resource, match)
        # resource: new incoming resource
        # matches: existing resource that matched with some %
        conflict_paths = find_conflict_paths(match)

        return nil if conflict_paths.blank?

        # left == new incoming resource; right == match
        source = match[:right]

        issue = create_issue(source.resourceType, source.id, 'Resource', resource.id, conflict_paths)
        FHIR::OperationOutcome.new(issue: [issue])
      end

      def self.score_match(left, right)
        left_path_maps = traverse(to_hash(left))

        right_path_maps = traverse(to_hash(right))

        { left: left, left_path_maps: left_path_maps,
          right: right, right_path_maps: right_path_maps,
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
        case obj
        when Hash
          prefix = path == '' ? '' : path + '.'
          obj.each { |k, v| traverse(v, path_map, prefix + k.to_s) }
        when Array
          # TODO: IMPORTANT -- this compares array contents by index
          # meaning 2 arrays with equivalent contents but different order
          # will not match. we should review
          obj.each_with_index { |v, i| traverse(v, path_map, "#{path}[#{i}]") }
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
        return 0 unless matchable_paths.any?

        match_count = 0

        matchable_paths.each do |p|
          if values_match?(left_path_maps[p], right_path_maps[p])
            match_count += 1
          elsif part_in_list?(p, REQUIRED_FIELDS)
            # the values don't match on this field which is required for the object to match
            # therefore we exit early
            return 0
          end
        end

        # Test how many of the common paths were a match. If the percentage of matches exceeds
        # the configurable MatchThreshold, we've got a match. At this point matchable_paths is
        # guaranteed not to be empty, making division by 0 impossible.
        match_count.to_f / matchable_paths.length
      end

      def self.find_conflict_paths(match_obj)
        left_path_maps = match_obj[:left_path_maps]
        left_keys = left_path_maps.keys

        right_path_maps = match_obj[:right_path_maps]
        right_keys = right_path_maps.keys

        # we can only match on paths in both resources
        common_paths = left_keys & right_keys
        # NOTE: ptmerge doesn't exclude "unsuitable paths" here, so different IDs would trigger a conflict
        matchable_paths = strip_unsuitable_paths(common_paths)

        left_only_paths = left_keys - right_keys
        right_only_paths = right_keys - left_keys

        conflict_paths = matchable_paths.find_all { |p| !values_match?(left_path_maps[p], right_path_maps[p]) }

        conflict_paths.push(*left_only_paths).push(*right_only_paths)

        conflict_paths
      end

      def self.strip_unsuitable_paths(paths)
        paths.reject { |p| part_in_list?(p, NON_COMPARABLE_PATHS) }
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
        begin
          if DATETIME_REGEX.match?(left) && DATETIME_REGEX.match?(right)
            left_date = Time.iso8601(left)
            right_date = Time.iso8601(right)
            return dates_match?(left_date, right_date)
          end
        rescue ArgumentError
          # the regex matched a date that the Time class didn't like
          # just ignore it and compare as a regular string
          Rails.logger.debug "Warning: #{left}, #{right} matched fhir_models DateTime regex, but aren't times"
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

      # return true if any single element of the given path exists in the given list
      def self.part_in_list?(path, list)
        list.any? { |ncp| path.downcase.split(/(?:\[(\d+)\])?\./).include?(ncp) }
      end

      def self.create_issue(source_resource_type, source_resource_id, target_resource_type, target_resource_id, conflict_paths)
        {
          severity: 'information',
          code: 'conflict',
          # The resource types and IDs are stored as additional diagnostic information.
          diagnostics: source_resource_type + ':' + source_resource_id.to_s + ';' + target_resource_type + ':' + target_resource_id.to_s,
          # Paths in the resource with conflicts, as a JSON path rather than XPath.
          location: conflict_paths
        }
      end
    end
  end
end
