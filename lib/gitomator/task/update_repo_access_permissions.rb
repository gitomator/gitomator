require 'gitomator/task'
require 'set'

module Gitomator
  module Task

    class UpdateRepoAccessPermissions < Gitomator::BaseTask

      #
      # @param context
      # @param repo_name [String]
      # @param user2perm [Hash<String,Symbol>] Map usernames to permission type (:read/:write).
      # @param team2perm [Hash<String,Symbol>] Map team-names to permission type (:read/:write).
      # @param opts [Hash]
      #
      def initialize(context, repo_name, user2perm, team2perm, opts={})
        super(context)
        @repo_name = repo_name
        @user2perm = user2perm || {}
        @team2perm = team2perm || {}
        @opts = opts
      end



      def run
        @user2perm.each do |username, permission|
          logger.info("Granting user #{username} #{permission} permission to #{@repo_name}")
          hosting.set_user_permission(username, @repo_name, permission)
        end

        @team2perm.each do |team_name, permission|
          logger.info("Granting team #{team_name} #{permission} permission to #{@repo_name}")
          hosting.set_team_permission(team_name, @repo_name, permission)
        end
      end



    end
  end
end
