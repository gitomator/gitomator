require 'gitomator/service/base'

module Gitomator
  module Service
    module Hosting
      class Service < Gitomator::Service::Base


        def initialize(provider, opts = {})
          super(provider, opts)
        end

        # ----------------------- CRUD operations on repos ---------------------

        def create_repo(name, opts={})
          _delegate(__callee__, name, opts)
        end

        def read_repo(name)
          _delegate(__callee__, name)
        end

        def update_repo(name, opts={})
          _delegate(__callee__, name, opts)
        end

        def delete_repo(name)
          _delegate(__callee__, name)
        end

        # ----------------------------------------------------------------------


        # ----------------------- CRUD operations on users ---------------------

        def create_user(name, opts={})
          raise "Unsupported"
        end

        def read_user(name)
          raise "Unsupported"
        end

        def update_user(name, opts={})
          raise "Unsupported"
        end

        def delete_user(name)
          raise "Unsupported"
        end

        # ----------------------------------------------------------------------

        # ----------------------- CRUD operations on teams ---------------------

        def create_team(name, opts={})
          _delegate(__callee__, name, opts)
        end

        def read_team(name)
          _delegate(__callee__, name)
        end

        def update_team(name, opts={})
          _delegate(__callee__, name, opts)
        end

        def delete_team(name)
          _delegate(__callee__, name)
        end

        # ----------------------------------------------------------------------


        # ------------ CRUD operations on group_memberships --------------------

        def create_group_membership(group, user, opts)
          raise "Unsupported"
        end

        def read_group_membership(group, user)
          raise "Unsupported"
        end

        def update_group_membership(group, user, opts)
          raise "Unsupported"
        end

        def delete_group_membership(group, user)
          raise "Unsupported"
        end

        # ----------------------------------------------------------------------

        # --------------- CRUD operations on permissions -----------------------

        #
        # @param user (String) username
        # @param repo (String) Repo name (full name, or repo-only)
        # @param permission (Symbol) Either :read or :write or nil
        #
        def set_user_permission(user, repo, permission)
          _delegate(__callee__, user, repo, permission)
        end

        #
        # @param user (String) username
        # @param team (String) Team name
        # @param permission (Symbol) Either :read or :write or nil
        #
        def set_team_permission(team, repo, permission)
          _delegate(__callee__, team, repo, permission)
        end

        # ----------------------------------------------------------------------


        # ------------------- CRUD operations on pull-requests -----------------

        def create_pull_reuqest(src, dst, opts)
          raise "Unsupported"
        end

        def read_pull_reuqest(src, dst)
          raise "Unsupported"
        end

        def update_pull_reuqest(src, dst, opts)
          raise "Unsupported"
        end

        def delete_pull_reuqest(src, dst)
          raise "Unsupported"
        end

        # ----------------------------------------------------------------------

      end
    end
  end
end
