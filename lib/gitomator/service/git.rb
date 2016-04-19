require 'gitomator/service'

module Gitomator
  module Service
    class Git < Gitomator::BaseService


      def initialize(provider, opts = {})
        super(provider, opts)
      end

      # ----------------------------------------------------------------------

      def clone(repo_url, local_repo_root, opts={})
        service_call(__callee__, repo_url, local_repo_root, opts)
      end

      def init(local_repo_root, opts={})
        service_call(__callee__, local_repo_root, opts)
      end

      def add(local_repo_root, path, opts={})
        service_call(__callee__, local_repo_root, path, opts)
      end

      def commit(local_repo_root, message, opts={})
        service_call(__callee__, local_repo_root, message, opts)
      end

      def checkout(local_repo_root, branch, opts={})
        service_call(__callee__, local_repo_root, branch, opts)
      end

      def set_remote(local_repo_root, remote, url, opts={})
        service_call(__callee__, local_repo_root, remote, url, opts)
      end

      def push(local_repo_root, remote, opts={})
        service_call(__callee__, local_repo_root, remote, opts)
      end

      def command(local_repo_root, command)
        service_call(__callee__, local_repo_root, command)
      end

    end
  end
end
