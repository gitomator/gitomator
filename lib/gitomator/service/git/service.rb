require 'gitomator/service/base'

module Gitomator
  module Service
    module Git
      class Service < Gitomator::Service::Base


        def initialize(provider, opts = {})
          super(provider, opts)
        end

        # ----------------------------------------------------------------------

        def clone(repo_url, local_repo_root, opts={})
          _delegate(__callee__, repo_url, local_repo_root, opts)
        end

        def init(local_repo_root, opts={})
          _delegate(__callee__, local_repo_root, opts)
        end

        def add(local_repo_root, path, opts={})
          _delegate(__callee__, local_repo_root, path, opts)
        end

        def commit(local_repo_root, message, opts={})
          _delegate(__callee__, local_repo_root, message, opts)
        end

        def checkout(local_repo_root, branch, opts={})
          _delegate(__callee__, local_repo_root, branch, opts)
        end

        def set_remote(local_repo_root, remote, url, opts={})
          _delegate(__callee__, local_repo_root, remote, url, opts)
        end

        def push(local_repo_root, remote, opts={})
          _delegate(__callee__, local_repo_root, remote, opts)
        end

        def command(local_repo_root, command)
          _delegate(__callee__, local_repo_root, command)
        end

      end
    end
  end
end
