require 'gitomator/github'
require 'gitomator/util/repo/name_resolver'


module Gitomator
  module GitHub
    class BaseProvider


      #
      # @param github_client [Octokit::Client]
      # @param github_organization [String]
      #
      def initialize(github_client, github_organization=nil)
        @gh  = github_client
        @org = github_organization
        @repo_name_resolver = Gitomator::Util::Repo::NameResolver.new(@org)
      end


      def name
        :github
      end


    end
  end
end
