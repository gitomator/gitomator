require 'gitomator/model/hosting/repo'
require 'gitomator/service/git/shell_based'

module Gitomator
  module Service
    module Hosting
      module Provider
        class Local

          def initialize(git_service, local_dir)
            @git        = git_service
            @local_dir  = local_dir
          end


          def name
            :local
          end

          def repo_root(name)
            File.join(@local_dir, name)
          end


          #
          # @return Gitomator::Model::Repo
          #
          def create_repo(name, opts)
            raise "Directory exists, #{repo_root(name)}" if Dir.exist? repo_root(name)
            @git.init(repo_root(name), opts)
            return Gitomator::Model::Hosting::Repo.new(name, "#{repo_root(name)}.git")
          end


          #
          # @return Gitomator::Model::Repo
          #
          def read_repo(name)
            if Dir.exist? repo_root(name)
              return Gitomator::Model::Hosting::Repo.new(name, "git@github.com:#{repo_root(name)}.git")
            else
              return nil
            end
          end


        end
      end
    end
  end
end
