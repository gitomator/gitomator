require 'gitomator/service/hosting/service'
require 'gitomator/model/hosting/repo'
require 'gitomator/model/hosting/team'
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
              return [@org, name]
            when 2
              return split_name
            else
              raise "Invalid repo name, '#{name}'"
            end
          end

          #---------------------------------------------------------------------

          def _team_to_model_obj(team)
            return Gitomator::Model::Hosting::Team.new(team.id, team.name,
                {
                  org: team.organization.login
                })
          end

          def _repo_to_model_obj(repo)
            return Gitomator::Model::Hosting::Repo.new(repo.name,
                repo.clone_url,
                {
                  name: repo.name,
                  description: repo.description,
                  homepage: repo.homepage,
                  private: repo.private?,
                  has_issues: repo.has_issues,
                  has_wiki: repo.has_wiki,
                  has_downloads: repo.has_downloads,
                  default_branch: repo.default_branch
                })
          end

          #---------------------------- REPO -----------------------------------

          #
          # opts:
          #   :auto_init (Boolean)
          #   :private (Boolean)
          #   :has_issues (Boolean)
          #   :has_wiki (Boolean)
          #   :has_download(Boolean)
          #
          def create_repo(name, opts = {})
            # Decide whether this is an organization-repo or a user-repo ...
            org = repo_name_org_only(name)
            unless org.nil? || org == @gh.user.login
              opts[:organization] = org
            end

            _repo_to_model_obj @gh.create_repo(repo_name_repo_only(name), opts)
          end

          def read_repo(name)
            begin
              _repo_to_model_obj @gh.repo repo_name_full(name)
            rescue Octokit::NotFound
              return nil
            end
          end

          #
          # opts:
          #   :name (String) — Name of the repo
          #   :description (String) — Description of the repo
          #   :homepage (String) — Home page of the repo
          #   :private (String) — true makes the repository private, and false makes it public.
          #   :has_issues (String) — true enables issues for this repo, false disables issues.
          #   :has_wiki (String) — true enables wiki for this repo, false disables wiki.
          #   :has_downloads (String) — true enables downloads for this repo, false disables downloads.
          #   :default_branch (String) — Update the default branch for this repository.
          #
          def update_repo(name, opts = {})
            unless opts.empty?
              _repo_to_model_obj @gh.edit_repository repo_name_full(name), opts
            end
          end


          def delete_repo(name)
            @gh.delete_repo repo_name_full(name)
          end



          #---------------------------- TEAMS ----------------------------------

          def create_team(name, opts = {})
              _team_to_model_obj @gh.create_team(@org, {name: name})
          end





        end
      end
    end
  end
end
