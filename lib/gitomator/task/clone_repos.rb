require 'gitomator/task/base_repos_task'

module Gitomator
  module Task
    class CloneRepos < Gitomator::Task::BaseReposTask


      #
      # @param context [Gitomator::Context]
      # @param repos [Array<String>] The repos to clone
      # @param local_dir [String] A local directory where the repos will be cloned.
      # @param opts [Hash]
      #
      def initialize(context, repos, local_dir, opts={})
        super(context, repos, local_dir)
        @opts      = opts

        before_processing_any_repos do
          logger.debug "Clonning #{repos.length} repo(s) into #{local_dir} ..."
        end

        after_processing_all_repos do |repo2result, repo2error|
          cloned  = repo2result.select {|_, result| result}.length
          skipped = repo2result.reject {|_, result| result}.length
          errored = repo2error.length
          logger.info "Done (#{cloned} cloned, #{skipped} skipped, #{errored} errors)"
        end
      end


      # override
      def process_repo(source, index)
        namespace = hosting.resolve_namespace(source)
        repo_name = hosting.resolve_repo_name(source)
        branch    = hosting.resolve_branch(source)

        local_repo_root = File.join(@local_dir, repo_name)
        if Dir.exist? local_repo_root
          logger.info "Local clone exists, #{local_repo_root}"
          return false
        end

        repo = hosting.read_repo(repo_name)
        raise "No such remote repo, #{repo_name}" if repo.nil?

        logger.info "git clone #{repo.url}"
        git.clone(repo.url, local_repo_root)

        unless branch.nil?
          logger.debug("Switching to remote branch #{branch}")
          git.checkout(local_repo_root, branch, {:is_new => true, :is_remote => true})
        end

        return true
      end



    end
  end
end
