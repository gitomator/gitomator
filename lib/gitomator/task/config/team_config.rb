module Gitomator
  module Task
    module Config

      class TeamConfig


        #=========================================================================
        # Static factory methods

        #
        # @param config [Hash] - Configuration data (e.g. parsed from a YAML file)
        # @return [Enumerable<Gitomator::Task::Config::TeamConfig>]
        #
        def self.from_hash(config)
          return config.map {|name, members| new(name, members) }
        end

        #=========================================================================


        attr_reader :name, :members  # Hash[String -> String], username to role

        #
        # @param name [String]
        # @param members_config [Array] Each item is either a string (username) or Hash with one entry (username -> role)
        #
        def initialize(name, members_config)
          @name    = name
          @members = parse_members_config(members_config)
        end


        def parse_members_config(members_config)
          result = {}

          members_config.each do |entry|
            if entry.is_a? String
              result[entry] = 'member' # Default role is 'member'
            elsif entry.is_a?(Hash) && entry.length == 1
              result[entry.keys.first] = entry.values.first
            else
              raise "Invalid team-member config, #{entry}."
            end
          end

          return result

        end


      end


    end
  end
end
