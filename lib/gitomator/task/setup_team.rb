require 'gitomator/task/base'
require 'set'

module Gitomator
  module Task

    class SetupTeam < Gitomator::Task::Base

      #
      # @param context
      # @param team_name [String]
      # @param member2role [Hash<String,String>] Map usernames to roles.
      # @param opts [Hash]
      #
      def initialize(context, team_name, member2role, opts={})
        super(context)
        @team_name   = team_name
        @member2role = member2role
        @opts = opts
      end



      def run
        create_team_if_missing()
        @member2role.each do |username, role|
          begin
            create_or_update_membership(username, role)
          rescue => e
            logger.error("Cannot create/update #{username}'s membership in #{@team_name} - #{e}.")
          end
        end
      end


      def create_team_if_missing
        if hosting.read_team(@team_name).nil?
          logger.info("Creating team: #{@team_name}")
          hosting.create_team(@team_name)
        else
          logger.debug("Team #{@team_name} exists.")
        end
      end


      def create_or_update_membership(username, role)
        membership = hosting.read_team_membership(@team_name, username)
        if membership.nil?
          logger.info("Adding #{username} to team #{@team_name} (role: #{role}).")
          hosting.create_team_membership(@team_name, username, {:role => role})
        elsif _get_role(membership) != role
          logger.info("Updating #{username}'s role from #{_get_role(membership)} to #{role} (team: #{@team_name})")
          hosting.update_team_membership(@team_name, username, {:role => role})
        else
          logger.debug("Skipping #{username}, already a #{role} of #{@team_name}.")
        end
      end


      # FIXME: This is a hack! This piece of logic belongs in gitomator-github.
      #
      # Once the gitomator and gitomator-github libraries are fully implemented,
      # the GitHub provider will return provider-agnostic Gitomator model object.
      # Then, we won't have to adapt here ...
      #
      def _get_role(membership)
        membership[:role] == 'maintainer' ? 'admin' : 'member'
      end


    end
  end
end
