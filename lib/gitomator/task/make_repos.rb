require 'tmpdir'
require 'gitomator/task/base_repos_task'
require 'gitomator/task/clone_repos'

module Gitomator
  module Task
    class MakeRepos < Gitomator::Task::BaseReposTask


      attr_reader :source_repo
      attr_reader :update_existing
      attr_reader :repo_properties
      attr_reader :source_repo_local_root

      #
      # @param context
      # @param repos [Array<String>]
      # @param opts [Hash<Symbol,Object>]
      # @option opts [Hash<Symbol,Object>] :repo_properties - For example, :private, :description, :has_issues, etc.
      # @option opts [String]  :source_repo - The name of a repo that will be the "starting point" of all the created repos.
      # @option opts [Boolean] :update_existing - Update existing repos, by pushing latest commit(s) from the source_repo.
      #
      def initialize(context, repos, opts={})
        super(context, repos)
        @opts  = opts

        @source_repo     = opts[:source_repo]
        @update_existing = opts[:update_existing] || false
        @repo_properties = opts[:repo_properties] || {}
        @repo_properties = @repo_properties.map {|k,v| [k.to_sym,v] }.to_h

        before_processing_any_repos do
          logger.info "About to create/update #{repos.length} repo(s) ..."

          if source_repo
            tmp_dir = Dir.mktmpdir('Gitomator_')
            Gitomator::Task::CloneRepos.new(context, [source_repo], tmp_dir).run()
            repo_name = hosting.resolve_repo_name(source_repo)
            @source_repo_local_root = File.join(tmp_dir, repo_name)
          end
        end
      end



      def process_repo(repo_name, index)
        repo = hosting.read_repo(repo_name)

        # If the repo doesn't exist, create it ...
        if repo.nil?
          logger.debug "Creating new repo #{repo_name} ..."
          repo = hosting.create_repo(repo_name, repo_properties)
          push_commits(repo, source_repo_local_root)

        # If the repo exists, we might need to push changes, or update its properties
        else
          if update_existing
            push_commits(repo, source_repo_local_root)
          end
          update_properties_if_needed(repo, repo_properties)
        end
      end


      def push_commits(hosted_repo, local_repo)
        if local_repo
          logger.debug "Pushing commits from #{local_repo} to #{hosted_repo.name} "
          git.set_remote(local_repo, hosted_repo.name, hosted_repo.url, {create: true})
          git.command(local_repo, "push #{hosted_repo.name} HEAD:master")
        end
      end


      def update_properties_if_needed(repo, props)
        p = repo.properties
        diff = props.select {|k,v| p.has_key?(k) && p[k] != v}
        unless(diff.empty?)
          logger.debug "Updating #{repo.name} properties #{diff}"
          hosting.update_repo(repo.name, diff)
        end
      end


    end
  end
end
