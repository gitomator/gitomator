require 'gitomator/gitom/hosting/base'

module Gitomator
  module Gitom
    module Hosting
      class Repo < Gitomator::Gitom::Hosting::Base

        def replay_args()
          return [data[:name], data[:opts]]
        end

      end
    end
  end
end
