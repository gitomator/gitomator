require 'gitomator/gitom/hosting/repo'

module Gitomator
  module Service
    module Hosting
      class Base

        def replay_gitom(gitom)
          self.send(gitom.action, *(gitom.replay_args))
        end

        # ----------------------- CRUD operations on repos ---------------------

        def create_repo(name, opts)
          raise "Unsupported"
        end

        def read_repo(name)
          raise "Unsupported"
        end

        def update_repo(name, opts)
          raise "Unsupported"
        end

        def delete_repo(name)
          raise "Unsupported"
        end

        # ----------------------------------------------------------------------


        # ----------------------- CRUD operations on users ---------------------

        def create_user(name, opts)
          raise "Unsupported"
        end

        def read_user(name)
          raise "Unsupported"
        end

        def update_user(name, opts)
          raise "Unsupported"
        end

        def delete_user(name)
          raise "Unsupported"
        end

        # ----------------------------------------------------------------------

        # ----------------------- CRUD operations on groups --------------------

        def create_group(name, opts)
          raise "Unsupported"
        end

        def read_group(name)
          raise "Unsupported"
        end

        def update_group(name, opts)
          raise "Unsupported"
        end

        def delete_group(name)
          raise "Unsupported"
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

        def create_permission(user_or_group, repo, opts)
          raise "Unsupported"
        end

        def read_permission(user_or_group, repo)
          raise "Unsupported"
        end

        def update_permission(user_or_group, repo, opts)
          raise "Unsupported"
        end

        def delete_permission(user_or_group, repo)
          raise "Unsupported"
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
