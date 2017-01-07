module Gitomator
  module GitHub
    module Model
      class HostedRepo


        #
        # @param gh_repo [Sawyer::Resource]
        #
        def initialize(gh_repo)
          @r = gh_repo
        end


        def name
          @r.name
        end

        def full_name
          @r.full_name
        end

        def url
          @r.clone_url
        end

        def properties
          return {
            :description    => @r.description,
            :homepage       => @r.homepage,
            :private        => @r.private?,
            :has_issues     => @r.has_issues?,
            :has_wiki       => @r.has_wiki?,
            :has_downloads  => @r.has_downloads?,
            :default_branch => @r.default_branch
          }
        end


      end
    end
  end
end
