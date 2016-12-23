
module Gitomator
  module Task
    module Config


      class ReposConfig

        attr_accessor :default_access_permission
        attr_accessor :repo_properties
        attr_accessor :source_repo

        #
        # @param config_obj [Hash] Configuration data (commonly loaded from a YAML file)
        #
        def initialize(config_obj)
          raise "Missing required key, repos" unless config_obj.has_key? 'repos'
          @repo2permissions = parse_repo2permissions(config_obj['repos'])

          default_access_permission = (config_obj['default_access_permission'] || :read).to_sym
          source_repo = config_obj['source_repo']
          repo_properties = config_obj['repo_properties'] || {}
        end


        #
        # @return [Enumerable<Strings>] The names of the repos.
        #
        def repos
          @repo2permissions.keys
        end

        #
        # @param repo [String] The name of a repository
        # @return [Hash<String,Symbol>] Map name (user or team) to permission (:read/:write/:admin)
        #
        def permissions(repo)
          @repo2permissions[repo]
        end


        # =================== Protected Helper Methods =========================

        protected


        #
        # Helper function.
        # @param repos_config [Array] Array of repo config items (various formats are supported)
        #
        def parse_repo2permissions(repos_config)
          repo2permissions = {}

          repos_config.each do |repo_config|
            repo_name   = nil
            permissions = {}

            # 1. Parse it ...
            if repo_config.is_a? String
              repo_name = repo_config
            elsif (repo_config.is_a? Hash) and (repo_config.length == 1)
              repo_name   = repo_config.keys.first.to_s
              permissions = parse_permissions(repo_config[repo_name])
            else
              raise Gitomator::Classroom::Exception::InvalidConfig.new(
                  "Cannot parse #{repo_config} (expected String or a Hash with one entry)")
            end

            # 2. Check if there was an error ...
            if repo2permissions.has_key? repo_config
              raise Gitomator::Classroom::Exception::InvalidConfig.new("Duplicate property, #{repo_config}")
            end

            # 3. If no error, store the information
            repo2permissions[repo_name] = permissions
          end

          return repo2permissions
        end


        #
        # Parse the permissions configuration of a single repo into a hash that
        # maps user/team names (Strings) to access-permissions (Symbols).
        #
        # Various configuration formats are supported:
        #  * String - Single name, with default permission
        #  * Hash - Maps names to permissions
        #  * Array<String/Hash> - An array mixing both of the previous options.
        #
        # @param permissions_config [String/Hash/Array]
        # @return [Hash<String,Symbol>]
        #
        def parse_permissions(permissions_config)
          if permissions_config.is_a? String
            return { permissions_config => default_access_permission }

          elsif permissions_config.is_a? Hash
            return permissions_config.map {|name,perm| [name, perm.to_sym] } .to_h

          elsif permissions_config.is_a? Array
            return permissions_config.map {|x| parse_permissions(x) } .reduce(:merge)

          else
            raise "Invalid permission configuration, #{permissions_config}"
          end
        end



      end


    end
  end
end
