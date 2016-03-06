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

            # GitHub API doesn't have a straight forward way to get a team by name,
            # so we'll keep a cahce in memory (String --> Gitomator::Model::Hosting::Team)
            @name2team_cache = {}
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
            return Gitomator::Model::Hosting::Team.new(team.name,
                {
                  id: team.id,
                  org: (team.organization.nil? ? @org : team.organization.login)
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


          def _fetch_teams
            name2team = {}

            begin
              @gh.auto_paginate = true # We want to get all teams
              @gh.org_teams(@org).each  do |t|
                name2team[t.name] = _team_to_model_obj(t)
              end
              @name2team_cache = name2team
            ensure
              @gh.auto_paginate = nil  # We don't want to hit GitHub's API rate-limit
            end
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

          def read_team(name)
            unless @name2team_cache.has_key? name
              _fetch_teams()
            end
            return @name2team_cache[name]
          end

          #
          # opts:
          #  - :name (String)
          #  - :permission (String, one of 'pull', 'push' or 'admin')
          #
          def update_team(name, opts)
            unless @name2team_cache.has_key? name
              _fetch_teams()
            end
            raise "No such team, '#{name}'" unless @name2team_cache.has_key? name

            t = @gh.update_team(@name2team_cache[name].opts[:id], opts)
            @name2team_cache[name] = _team_to_model_obj(t)
          end

          def delete_team(name)
            unless @name2team_cache.has_key? name
              _fetch_teams()
            end
            if @name2team_cache.has_key? name
              @gh.delete_team @name2team_cache[name].opts[:id]
              @name2team_cache.delete(name)
            end
          end


          #---------------------------------------------------------------------

          def set_user_permission(user, repo, permission)
            permission = _strinigify_permission(permission)
            if permission.nil?
              @gh.remove_collab(repo_name_full(repo), user)
            else
              @gh.add_collab(repo_name_full(repo), user, {permission: permission})
            end
          end


          def set_team_permission(team, repo, permission)
            permission = _strinigify_permission(permission)

            t = read_team(team)
            raise "No such team, #{team}" if t.nil?

            if permission.nil?
              @gh.remove_team_repo(t.opts[:id], repo_name_full(repo))
            else
              @gh.add_team_repo(t.opts[:id], repo_name_full(repo),
                {
                  permission: permission,
                  accept: 'application/vnd.github.ironman-preview+json'
                }
              )
            end
          end


          def _strinigify_permission(permission)
            if permission.nil?
              return nil
            end

            case permission.to_s
            when 'read' || 'pull'
              return 'pull'
            when 'write' || 'push'
              return 'push'
            else
              raise "Invalid permission '#{permission}'"
            end
          end


          #--------------------------- Team Membership -------------------------

          def create_team_membership(team_name, user_name, opts={})
            team = read_team(team_name)
            opts[:role] = 'member' if opts[:role].nil?
            @gh.add_team_membership(team.opts[:id], user_name, opts).to_h
          end


          def read_team_membership(team_name, user_name)
            team = read_team(team_name)
            begin
              return @gh.team_membership(team.opts[:id], user_name).to_h
            rescue Octokit::NotFound
              return nil
            end
          end


          #
          # The only valid option is :role, which must be one of 'member' or
          # 'maintainer'.
          #
          def update_team_membership(team_name, user_name, opts={})
            raise "Missing required option, :role" if opts[:role].nil?
            team = read_team(team_name)
            @gh.add_team_membership(team.opts[:id], user_name, opts).to_h
          end

          def delete_team_membership(team_name, user_name)
            team = read_team(team_name)
            @gh.remove_team_membership(team.opts[:id], user_name)
          end


          #---------------------------------------------------------------------



        end
      end
    end
  end
end
