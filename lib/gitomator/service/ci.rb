require 'gitomator/service'

module Gitomator
  module Service
    class CI < Gitomator::BaseService


      def initialize(provider, opts = {})
        super(provider, opts)
      end


      def sync(blocking=false, opts={})
        service_call(__callee__, blocking, opts)
      end

      def syncing?(opts={})
        service_call(__callee__, opts)
      end

      def enable_ci(repo, opts={})
        service_call(__callee__, repo, opts)
      end

      def disable_ci(repo, opts={})
        service_call(__callee__, repo, opts)
      end

      def ci_enabled?(repo)
        service_call(__callee__, repo)
      end

    end
  end
end
