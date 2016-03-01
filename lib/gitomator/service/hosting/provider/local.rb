require 'gitomator/model/hosting/repo'
require 'fileutils'

module Gitomator
  module Service
    module Hosting
      module Provider
        class Local

          attr_reader :local_dir, :local_repos_dir

          def initialize(git_service, local_dir, opts = {})
            @git         = git_service

            raise "Local directory doesn't exist, #{local_dir}" unless Dir.exist? local_dir
            @local_dir   = local_dir

            @local_repos_dir = File.join(@local_dir, opts[:repos_dir] || 'repos')
            Dir.mkdir @local_repos_dir unless Dir.exist? @local_repos_dir
          end

          #---------------------------------------------------------------------

          def name
            :local
          end


          def repo_root(name)
            File.join(local_repos_dir, name)
          end

          #---------------------------------------------------------------------

          def create_repo(name, opts)
            raise "Directory exists, #{repo_root(name)}" if Dir.exist? repo_root(name)
            @git.init(repo_root(name), opts)
            return Gitomator::Model::Hosting::Repo.new(name, "#{repo_root(name)}/.git")
          end


          def read_repo(name)
            if Dir.exist? repo_root(name)
              return Gitomator::Model::Hosting::Repo.new(name, "#{repo_root(name)}/.git")
            else
              return nil
            end
          end


          def update_repo(name)
            # Local-provider doesn't support updating (the meta data of) a repo
            return read_repo(name)
          end


          def delete_repo(name)
            if Dir.exist? repo_root(name)
              FileUtils.rm_rf repo_root(name)
            else
              raise "No such repo, '#{name}'"
            end
            return nil
          end


        end
      end
    end
  end
end
