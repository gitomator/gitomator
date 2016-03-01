require 'gitomator/service/hosting/service'
require 'gitomator/model/hosting/repo'
require 'octokit'

module Gitomator
  module Service
    module Hosting
      module Provider
        class GitHub

          def initialize(access_token, opts = {})
            @gh = Octokit::Client.new(:access_token => access_token)
            @org = opts[:org]
          end

          def name
            :github
          end


          # ------------ Helper Methods, Dealing With Naming Conventions -------

          def repo_name_full(repo_name)
            _tokenize_repo_name(repo_name).join "/"
          end

          def repo_name_org_only(repo_name)
            _tokenize_repo_name(repo_name).first
          end

          def repo_name_repo_only(repo_name)
            _tokenize_repo_name(repo_name).last
          end


          def _tokenize_repo_name(name)
            split_name = name.split "/"
            case split_name.length
            when 1
              raise "Invalid repo name, '#{name}'. No user/org specified." if @org.nil?
              return [@org, name]
            when 2
              return split_name
            else
              raise "Invalid repo name, '#{name}'"
            end
          end

          #---------------------------------------------------------------------

          def _to_model_obj(repo)
            return Gitomator::Model::Hosting::Repo.new(repo.name,
                repo.clone_url, {r: repo})
          end

          #---------------------------------------------------------------------


          def create_repo(name, opts = {})
            opts = {
              :organization => repo_name_org_only(name),
              :auto_init => false,  # Don't create a README.md automatically
              :private => false,
              :has_issues => false,
              :has_wiki => false,
              :has_downloads => true
            }.merge(opts)

            _to_model_obj @gh.create_repo(repo_name_full(name), opts)
          end

          def read_repo(name)
            _to_model_obj @gh.repo repo_name_full(name)
          end

          def update_repo(name, opts = {})
            raise "Unsupported"
          end

          def delete_repo(name)
            raise "Unsupported"
          end

          def rename_repo(old_name, new_name, opts={})
            raise "Unsupported"
          end




        end
      end
    end
  end
end
