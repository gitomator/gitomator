require 'gitomator/task'

module Gitomator
  module Task
    class CloneRepos < Gitomator::BaseTask


      #
      # @param context [Gitomator::Context]
      # @param repos [Array<String>] The repos to clone
      # @param local_dir [String] A local directory where the repos will be cloned.
      # @param opts [Hash]
      #
      def initialize(context, repos, local_dir, opts={})
        super(context)
        @repos     = repos
        @local_dir = local_dir
        @opts      = opts
        raise "No such folder, #{@local_dir}." unless Dir.exists? @local_dir
      end


      def run
        logger.debug "Clonning #{@repos.length} repo(s) into #{@local_dir} ..."

        @repos.each_with_index do |repo_name, index|
          begin
            clone_repo(repo_name, index)
          rescue => e
            on_error(repo_name, index, e)
          end
        end

        logger.debug "Done."
      end


      def clone_repo(source, index)
        namespace = hosting.resolve_namespace(source)
        repo_name = hosting.resolve_repo_name(source)
        branch    = hosting.resolve_branch(source)

        local_repo_root = File.join(@local_dir, repo_name)
        if Dir.exist? local_repo_root
          logger.info "Repo #{repo_name} already exists at #{local_repo_root}."
          return
        end

        repo = hosting.read_repo(repo_name)
        raise "Repo #{repo_name} doesn't exist" if repo.nil?

        logger.info "Clonning #{repo.url} (#{index + 1} out of #{@repos.length}) ..."
        git.clone(repo.url, local_repo_root)

        unless branch.nil?
          logger.debug("Switching to remote branch #{branch}")
          git.checkout(local_repo_root, branch, {:is_new => true, :is_remote => true})
        end
      end


      def on_error(repo_name, index, err)
        logger.error "#{err} (#{repo_name}).\n\n#{err.backtrace.join("\n\t")}"
      end


    end
  end
end
