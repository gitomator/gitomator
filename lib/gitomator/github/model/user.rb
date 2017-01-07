module Gitomator
  module GitHub
    module Model
      class User


        #
        # @param gh_user [Sawyer::Resource]
        #
        def initialize(gh_user)
          @r = gh_user
        end

        def username
          @r.login
        end

      end
    end
  end
end
