require 'gitomator/service'

module Gitomator
  module Service
    class Hosting < Gitomator::BaseService


      def initialize(provider, opts = {})
        super(provider, opts)
      end

      # ----------------------- CRUD operations on repos ---------------------

      def create_repo(name, opts={})
        service_call(__callee__, name, opts)
      end

      def read_repo(name)
        service_call(__callee__, name)
      end

      def update_repo(name, opts={})
        service_call(__callee__, name, opts)
      end

      def delete_repo(name)
        service_call(__callee__, name)
      end

      def search_repos(query, opts={})
        service_call(__callee__, query, opts)
      end

      # ----------------------- CRUD operations on teams ---------------------

      def create_team(name, opts={})
        service_call(__callee__, name, opts)
      end

      def read_team(name)
        service_call(__callee__, name)
      end

      def update_team(name, opts={})
        service_call(__callee__, name, opts)
      end

      def delete_team(name)
        service_call(__callee__, name)
      end

      def search_teams(query, opts={})
        service_call(__callee__, query, opts)
      end

      # ----------------------------------------------------------------------

      def search_users(query, opts={})
        service_call(__callee__, query, opts)
      end

      # ------------ CRUD operations on team_memberships ---------------------


      def create_team_membership(team_name, user_name, opts={})
        service_call(__callee__, team_name, user_name, opts)
      end

      def read_team_membership(team_name, user_name)
        service_call(__callee__, team_name, user_name)
      end

      def update_team_membership(team_name, user_name, opts={})
        service_call(__callee__, team_name, user_name, opts)
      end

      def delete_team_membership(team_name, user_name)
        service_call(__callee__, team_name, user_name)
      end

      # --------------- CRUD operations on permissions -----------------------

      #
      # @param user (String) username
      # @param repo (String) Repo name (full name, or repo-only)
      # @param permission (Symbol) Either :read or :write or nil
      #
      def set_user_permission(user, repo, permission)
        service_call(__callee__, user, repo, permission)
      end

      #
      # @param user (String) username
      # @param team (String) Team name
      # @param permission (Symbol) Either :read or :write or nil
      #
      def set_team_permission(team, repo, permission)
        service_call(__callee__, team, repo, permission)
      end

      # ----------------------------------------------------------------------


      # ------------------- CRUD operations on pull-requests -----------------
      #
      # We assume that pull-requests have id's, and that id's are
      # unique within a repo.
      # That is, the pair (dest_repo, id) uniquely identifies a pull-request.
      #



      def create_pull_request(src, dst, opts = {})
        service_call(__callee__, src, dst, opts)
      end



      def read_pull_request(dst_repo, id)
        service_call(__callee__, dst_repo, id)
      end

      def read_pull_requests(dst_repo, opts = {})
        service_call(__callee__, dst_repo, opts)
      end


      # Pull-request update methods:


      def merge_pull_request(dst_repo, id, message='')
        service_call(__callee__, dst_repo, id, message)
      end

      def close_pull_request(dst_repo, id)
        service_call(__callee__, dst_repo, id)
      end

      def open_pull_request(dst_repo, id)
        service_call(__callee__, dst_repo, id)
      end


      #
      # A "general-purpose" update method for pull-requests.
      #
      def update_pull_request(dst_repo, id, opts)
        service_call(__callee__, dst_repo, id)
      end



      def delete_pull_request(dst_repo, id)
        service_call(__callee__, dst_repo, id)
      end


    end
  end
end
