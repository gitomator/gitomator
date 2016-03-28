require 'gitomator/service/base'

module Gitomator
  module Service
    module CI
      class Service < Gitomator::Service::Base


        def initialize(provider, opts = {})
          super(provider, opts)
        end



        def enable_ci(repo, opts={})
          _delegate(__callee__, repo, opts)
        end

        def disable_ci(repo, opts={})
          _delegate(__callee__, repo, opts)
        end

      end
    end
  end
end
