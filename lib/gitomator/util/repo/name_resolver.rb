module Gitomator
  module Util
    module Repo

      #
      # Convenience class dealing with repo names of the format "namespace/name".
      #
      class NameResolver

        attr_reader :default_namespace

        def initialize(default_namespace=nil)
          @default_namespace = default_namespace
        end


        def full_name(repo_name)
          tokenize(repo_name).join("/")
        end

        def namespace_only(repo_name)
          tokenize(repo_name).first
        end

        def name_only(repo_name)
          tokenize(repo_name).last
        end

        #
        # Return an array with two strings, the namespace and name of the given
        # repo. If the given repo is missing a namespace, self's default
        # namespace will be used.
        #
        # @param name [String] - The name of the repo in the format "namespace/name".
        #
        def tokenize(name)
          split_name = name.split "/"
          case split_name.length
          when 1
            return [@default_namespace, name]
          when 2
            return split_name
          else
            raise "Invalid repo name, '#{name}'."
          end
        end


      end
    end
  end
end
