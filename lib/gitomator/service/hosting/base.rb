require 'gitomator/gitom/hosting/repo'

module Gitomator
  module Service
    module Hosting
      class Base

        def replay_gitom(gitom)
          self.send(gitom.action, *(gitom.replay_args))
        end

      end
    end
  end
end
