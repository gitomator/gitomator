require 'gitomator/task/base_repos_task'

module Gitomator
  module Task

    #
    # Abstract parent class
    #
    class EnableDisableCI < Gitomator::Task::BaseReposTask

      #
      # @param context - Has a `ci` method that returns a Gitomator::Service::CI
      # @param repos [Array<String>] - Names of the repos to enable/disable CI on.
      # @param opts [Hash<Symbol,Object>] - Task options
      # @option opts [Boolean] :sync - Indicate whether we should start by sync'ing the CI service.
      #
      def initialize(context, repos, opts={})
        super(context, repos)

        if opts[:sync]
          before_processing_any_repos do
            logger.info "Syncing CI service (this may take a little while) ..."
            ci.sync()
            while ci.syncing?
              print "."
              sleep 1
            end
            puts ""
            logger.info "CI service synchronized"
          end
        end
      end


    end



    class EnableCI < EnableDisableCI
      def process_repo(repo_name, i)
        logger.info "Enabling CI for #{repo_name} (#{i + 1} out of #{repos.length})"
        ci.enable_ci repo_name
      end
    end


    class DisableCI < EnableDisableCI
      def process_repo(repo_name, i)
        logger.info "Disabling CI for #{repo_name} (#{i + 1} out of #{repos.length})"
        ci.disable_ci repo_name
      end
    end


  end
end
