module Gitomator
  module Service
    module Git
      class Base  # Essentially, the interface for a generic Git service

        def clone(repo_url, local_repo_root, opts)
          raise "Unsupported"
        end

        def init(local_repo_root, opts)
          raise "Unsupported"
        end

        def add(local_repo_root, path, opts)
          raise "Unsupported"
        end

        def commit(local_repo_root, message, opts)
          raise "Unsupported"
        end

        def checkout(local_repo_root, branch, opts)
          raise "Unsupported"
        end

        def set_remote(local_repo_root, remote, url, opts)
          raise "Unsupported"
        end

        def push(local_repo_root, remote, opts)
          raise "Unsupported"
        end

      end
    end
  end
end
