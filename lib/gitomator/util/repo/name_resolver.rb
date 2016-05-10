module Gitomator
  module Util
    module Repo

      #
      # Convenience class dealing with repo names of the format
      # `NAMESPACE/REPO:BRANCH`.
      #
      class NameResolver

        attr_reader :default_namespace

        def initialize(default_namespace=nil)
          @default_namespace = default_namespace
        end


        def full_name(repo_name)
          namespace, name = tokenize(repo_name)
          if namespace.nil?
            return name
          else
            return "#{namespace}/#{name}"
          end
        end

        def namespace(name)
          tokenize(name)[0]
        end

        def name_only(name)
          tokenize(name)[1]
        end

        def branch(name)
          tokenize(name)[2]
        end

        #
        # Given a string of the format "namespace/name:branch", return an array
        # with three strings:
        #  1. Namespace
        #  2. Repo-name
        #  3. branch
        #
        # If the namespace is missing, self's default namespace will be used.
        #
        # @param name [String] - The name of the repo in the format "namespace/name:branch".
        #
        def tokenize(name)
          m = /^([\w-]+\/)?([\w-]+)(\:[\w-]+)?$/.match(name)

          raise "Invalid repo name, '#{name}'." if m.nil?

          namespace = m[1] || @default_namespace
          namespace = namespace.gsub('/', '') unless namespace.nil?
          repo = m[2]
          branch = m[3]
          branch = branch.gsub(':', '') unless branch.nil?

          return [namespace, repo, branch]
        end


      end
    end
  end
end
