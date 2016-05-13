require 'tmpdir'
require 'gitomator/task'
require 'gitomator/task/clone_repos'

module Gitomator
  module Task
    class MakeRepos < Gitomator::BaseTask


      #
      # @param context
      # @param repos [Array<String>]
      # @param opts [Hash<Symbol,Object>]
      # @option opts [Hash<Symbol,Object>] :repo_properties - For example, :private, :description, :has_issues, etc.
      # @option opts [String]  :source_repo - The name of a repo that will be the "starting point" of all the created repos.
      # @option opts [Boolean] :update_existing - Update existing repos, by pushing latest commit(s) from the source_repo.
      #
      def initialize(context, repos, opts={})
        super(context)
        @repos = repos
        @opts  = opts

        @source_repo     = opts[:source_repo]
        @update_existing = opts[:update_existing] || false
        @repo_properties = opts[:repo_properties] || {}
        @repo_properties = @repo_properties.map {|k,v| [k.to_sym,v] }.to_h
      end


      def run
        logger.info "About to make #{@repos.length} repo(s) ..."

        source_repo_local_root = nil
        if @source_repo
          tmp_dir = Dir.mktmpdir('Gitomator_')
          Gitomator::Task::CloneRepos.new(context, [@source_repo], tmp_dir).run()
          source_repo_local_root = File.join(tmp_dir, hosting.resolve_repo_name(@source_repo))
        end


        @repos.each_with_index do |repo_name, index|
          begin
            logger.info "#{repo_name} (#{index + 1} out of #{@repos.length})"
            repo = hosting.read_repo(repo_name)

            # If the repo doesn't exist, create it ...
            if repo.nil?
              logger.debug "Creating new repo #{repo_name} ..."
              repo = hosting.create_repo(repo_name, @repo_properties || {})
              push_commits(repo, source_repo_local_root)

            # If the repo exists, we might need to push changes, or update its properties
            else
              if @update_existing
                push_commits(repo, source_repo_local_root)
              end
              update_properties_if_needed(repo, @repo_properties || {})
            end

          rescue => e
            on_error(repo_name, index, e)
          end
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



      def on_error(repo_name, index, err)
        logger.error "#{err} (#{repo_name}).\n\n#{err.backtrace.join("\n\t")}"
      end


    end
  end
end
