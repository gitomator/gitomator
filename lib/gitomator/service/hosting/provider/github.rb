require 'gitomator/service/hosting/service'
require 'gitomator/model/hosting/repo'

module Gitomator
  module Service
    module Hosting
      module Provider
        class GitHub

          def name
            :github
          end


          #
          # @return Gitomator::Gitom::Base instance
          #
          def create_repo(name, opts)
            return Gitomator::Model::Hosting::Repo.new(name, "git@github.com:#{name}.git", opts)
          end


          #
          # @return Gitomator::Model::Repo
          #
          def read_repo(name)
            return Gitomator::Model::Hosting::Repo.new(name, "git@github.com:#{name}.git", {})
          end


        end
      end
    end
  end
end
