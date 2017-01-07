require 'gitomator/github'
require 'gitomator/github/base_provider'
require 'gitomator/github/model/hosted_repo'
require 'gitomator/github/model/pull_request'
require 'gitomator/github/model/team'
require 'gitomator/github/model/user'
require 'gitomator/util/repo/name_resolver'


module Gitomator
  module GitHub
    class HostingProvider < Gitomator::GitHub::BaseProvider

      #
      # @param config [Hash<String,Object>]
      # @return [Gitomator::GitHub::HostingProvider] GitHub hosting provider.
      #
      def self.from_config(config = {})
        org = config['organization'] || config[:organization]
        return new(Gitomator::GitHub::github_client_from_config(config), org)
      end


      #=========================================================================

      #
      # @param github_client [Octokit::Client]
      # @param github_organization [String]
      # @param opts [Hash]
      #
      def initialize(github_client, github_organization=nil)
        super
        # GitHub API doesn't have a straight forward way to get a team by name, so we'll keep an in-memory cache
        @name2team_cache = {}
      end

      def name
        :github
      end


      # ------------ Helper Methods, Dealing With Naming Conventions -------

      def repo_name_full(repo_name)
        @repo_name_resolver.full_name(repo_name)
      end

      #---------------------------------------------------------------------

      def _fetch_teams
        with_auto_paginate do
          @name2team_cache = @gh.org_teams(@org).map {|t| [t.name, t]} .to_h
        end
      end


      #---------------------------- REPO -----------------------------------

      SUPPORTED_CREATE_OPTS = [:description, :homepage, :private, :has_issues,
                               :has_wiki, :has_downloads, :auto_init]
      #
      # @option opts [String]  :description
      # @option opts [String]  :homepage
      # @option opts [Boolean] :private
      # @option opts [Boolean] :has_issues
      # @option opts [Boolean] :has_wiki
      # @option opts [Boolean] :has_downloads
      # @option opts [Boolean] :auto_init
      #
      def create_repo(name, opts = {})
        opts = opts.select {|k,_| SUPPORTED_CREATE_OPTS.include? k }

        # Decide whether this is an organization-repo or a user-repo ...
        org = @repo_name_resolver.namespace(name)
        unless org.nil? || org == @gh.user.login
          opts[:organization] = org
        end

        return Gitomator::GitHub::Model::HostedRepo.new(
          @gh.create_repo(@repo_name_resolver.name_only(name), opts)
        )
      end


      def read_repo(name)
        begin
          return Gitomator::GitHub::Model::HostedRepo.new(@gh.repo repo_name_full(name))
        rescue Octokit::NotFound
          return nil
        end
      end


      SUPPORTED_UPDATE_OPTS = [:name, :description, :homepage, :private,
                               :has_issues, :has_wiki, :has_downloads,
                               :default_branch]
      #
      # @option opts [String]  :name — Name of the repo
      # @option opts [String]  :description — Description of the repo
      # @option opts [String]  :homepage — Home page of the repo
      # @option opts [Boolean] :private — true makes the repository private, and false makes it public.
      # @option opts [Boolean] :has_issues — true enables issues for this repo, false disables issues.
      # @option opts [Boolean] :has_wiki — true enables wiki for this repo, false disables wiki.
      # @option opts [Boolean] :has_downloads — true enables downloads for this repo, false disables downloads.
      # @option opts [String]  :default_branch — Update the default branch for this repository.
      #
      def update_repo(name, opts = {})
        opts = opts.select {|k,_| SUPPORTED_UPDATE_OPTS.include? k }
        unless opts.empty?
          return Gitomator::GitHub::Model::HostedRepo.new(
                @gh.edit_repository repo_name_full(name), opts)
        end
      end


      def delete_repo(name)
        @gh.delete_repo repo_name_full(name)
      end

      #
      # For opts see http://www.rubydoc.info/gems/octokit/Octokit%2FClient%2FSearch%3Asearch_issues
      #
      def search_repos(query, opts = {})
        gh_repos = nil
        with_auto_paginate do
          gh_repos = @gh.search_repos("#{query} user:#{@org}", opts).items
        end

        gh_repos.map {|r| Gitomator::GitHub::Model::HostedRepo.new(r)}
      end


      #---------------------------- TEAMS ----------------------------------

      def create_team(name, opts = {})
          Gitomator::GitHub::Model::Team.new(@gh.create_team(@org, {name: name}))
      end

      def read_team(name)
        unless @name2team_cache.has_key? name
          _fetch_teams()
        end
        if @name2team_cache[name]
          Gitomator::GitHub::Model::Team.new(@name2team_cache[name])
        else
          return nil
        end
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

        t = @gh.update_team(@name2team_cache[name].id, opts)
        @name2team_cache[name] = t
        return Gitomator::GitHub::Model::Team.new(t)
      end

      def delete_team(name)
        unless @name2team_cache.has_key? name
          _fetch_teams()
        end
        if @name2team_cache.has_key? name
          @gh.delete_team @name2team_cache[name].id
          @name2team_cache.delete(name)
          return true
        end
        return false
      end


      def search_teams(query, opts={})
        result = @name2team_cache.select {|k,_| k.downcase.include? query} .values
        if result.empty?
          _fetch_teams()
          result = @name2team_cache.select {|k,_| k.downcase.include? query} .values
        end
        return result.map {|t| Gitomator::GitHub::Model::Team.new(t)}
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
          @gh.remove_team_repo(t.id, repo_name_full(repo))
        else
          @gh.add_team_repo(t.id, repo_name_full(repo),
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

      #----------- Helpers ---------

      def gitomator_role_2_github_role(role)
        if ['admin', 'maintainer'].include? role.to_s.downcase
          return 'maintainer'
        else
          return 'member'
        end
      end

      def github_role_2_gitomator_role(role)
        role == 'maintainer' ? 'admin' : role
      end

      def team_id(team_name)
        team = read_team(team_name)
        raise "No such team, #{team_name}" if team.nil?
        return team.id
      end

      #-----------------------------


      def create_team_membership(team_name, user_name, role='member')
        @gh.add_team_membership(team_id(team_name), user_name,
          { :role => gitomator_role_2_github_role(role) }
        )
        return role
      end


      def read_team_membership(team_name, user_name)
        begin
          m = @gh.team_membership(team_id(team_name), user_name)
          return m.nil? ? nil : m.role
        rescue Octokit::NotFound
          return nil
        end
      end


      def update_team_membership(team_name, user_name, role)
        @gh.add_team_membership(team_id(team_name), user_name,
          { :role => gitomator_role_2_github_role(role) } )
        return role
      end


      def delete_team_membership(team_name, user_name)
        @gh.remove_team_membership(team_id(team_name), user_name)
      end


      #---------------------------------------------------------------------

      def with_auto_paginate
        raise "You must supply a block" unless block_given?
        begin
          @gh.auto_paginate = true # We want to get all team members
          yield
        ensure
          @gh.auto_paginate = nil  # We don't want to hit GitHub's API rate-limit
        end
      end


      def search_users(query, opts={})

        # If the team's name is specified ...
        gh_users = nil
        if opts[:team_name]
          team = read_team(opts[:team_name])
          gh_users = with_auto_paginate { @gh.team_members(team.id) }
        else
          gh_users = with_auto_paginate { @gh.org_members(@org) }
        end

        result = gh_users.map { |u| Gitomator::GitHub::Model::User.new(u) }

        if query.is_a?(String) && (! query.empty?)
          result = result.select {|u| u.username.include? query }
        elsif query.is_a? Regexp
          result = result.select {|u| query.match(u.username) }
        end

        return result
      end


      #---------------------------------------------------------------------


      #
      # @param src (String) of the following format 'org/repo:branch'.
      # @param dst (String) of the following format 'org/repo:branch'.
      #
      def create_pull_request(src, dst, opts = {})

        def extract_org_repo_and_branch(src_or_dst)
          match = src_or_dst.match(/(.+)\/(.+):(.+)/i)
          raise "Invalid src/dst, #{src_or_dst} (expected: `org_or_user/repo:branch`)" if match.nil?
          return match.captures
        end

        src_org, src_repo, src_branch = extract_org_repo_and_branch(src)
        dst_org, dst_repo, dst_branch = extract_org_repo_and_branch(dst)

        unless src_repo == dst_repo
          raise "Cannot create pull-request from #{src} to #{dst} (must be the same repo or a fork)."
        end

        Gitomator::GitHub::Model::PullRequest.new(
          @gh.create_pull_request("#{dst_org}/#{dst_repo}", dst_branch,
            (src_org == dst_org ? '' : "#{src_org}:") + src_branch,
            opts[:title] || 'New Pull Request',
            opts[:body] || 'Pull-request created using Gitomator.'
          )
        )
      end


      def read_pull_request(dst_repo, id)
        begin
          return Gitomator::GitHub::Model::PullRequest.new(
                        @gh.pull_request(repo_name_full(dst_repo), id))
        rescue Octokit::NotFound
          return nil
        end
      end


      #
      # @param opts [Hash]
      # => @param :state [Symbol] One of :open, :close or :all (default: :open)
      #
      def read_pull_requests(dst_repo, opts = {})
        @gh.pulls(repo_name_full(dst_repo), opts)
                .map {|pr| Gitomator::GitHub::Model::PullRequest.new(pr, @gh)}
      end


      def merge_pull_request(dst_repo, id, message='')
        Gitomator::GitHub::Model::PullRequest.new(
          @gh.merge_pull_request(repo_name_full(dst_repo), id, message), @gh)
      end

      def close_pull_request(dst_repo, id)
        Gitomator::GitHub::Model::PullRequest.new(
          @gh.close_pull_request(repo_name_full(dst_repo), id), @gh)
      end

      def open_pull_request(dst_repo, id)
        Gitomator::GitHub::Model::PullRequest.new(
          @gh.update_pull_request(repo_name_full(dst_repo), id, {state: :open}), @gh)
      end


      #---------------------------------------------------------------------



    end
  end
end
