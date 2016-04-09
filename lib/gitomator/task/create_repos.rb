require 'gitomator/task/base'

module Gitomator
  module Task
    class CreateRepos < Gitomator::Task::Base


      #
      # @param context
      # @param repos [Array<String>]
      # @param opts [Hash<Symbol,Object>]
      # @option opts [Hash]    :create_opts - Options Hash that will be passed to the hosting service when creating the repos.
      # @option opts [String]  :source_repo - The name of a repo that will be the "starting point" of all the created repos.
      # @option opts [String]  :source_repo_url - Same as :source_repo, but specifies a URL
      # @option opts [Boolean] :update_existing - Indicate whether we should update repos that were already created (with recent changes from the source_repo, assuming one was provided).
      #
      def initialize(context, repos, opts={})
        super(context)
        @repos = repos
        @opts  = opts
      end


      def run
        logger.info "About to create #{@repos.length} repo(s) ..."

        @repos.each_with_index do |repo_name, index|
          begin
            if (hosting.read_repo(repo_name).nil?)
              logger.info "Creating #{repo_name} (#{index + 1} out of #{@repos.length}) ..."
              hosting.create_repo(repo_name)
            else
              logger.info "Skipping #{repo_name}, repo already exists."
            end
          rescue => e
            on_error(repo_name, index, e)
          end
        end

      end


    end
  end
end
