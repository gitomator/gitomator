require "gitomator/version"

module Gitomator
  module Console


    def self.context=(context)
      @context = context
    end

    def self.context()
      @context
    end

    # ==========================================================================

    def gitomator_version
      Gitomator::VERSION
    end

    def gitomator_context
      Gitomator::Console::context
    end



    def search_repos(query)
      gitomator_context.hosting.search_repos(query).map {|r| r.full_name}
    end

    def delete_repo(repo_name)
      gitomator_context.hosting.delete_repo(repo_name)
    end



    def search_teams(query)
      gitomator_context.hosting.search_teams(query).map {|t| t.name}
    end

    def delete_team(team_name)
      gitomator_context.hosting.delete_team(team_name)
    end


  end
end
