require 'tmpdir'
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
      #
      def initialize(context, repos, opts={})
        super(context)
        @repos = repos
        @opts  = opts
      end


      def run
        logger.info "About to create #{@repos.length} repo(s) ..."

        source_repo_local_root = nil
        if @opts[:source_repo]
          source_repo_local_root = File.join(Dir.mktmpdir('Gitomator_'), @opts[:source_repo])
          logger.info "Cloning source repo #{@opts[:source_repo]} into #{source_repo_local_root} ..."
          git.clone(hosting.read_repo(@opts[:source_repo]).url, source_repo_local_root)
        end


        @repos.each_with_index do |repo_name, index|
          begin
            repo = create_repo_if_missing(repo_name, index)
            if(source_repo_local_root)
              update_repo(repo, source_repo_local_root)
            end
          rescue => e
            on_error(repo_name, index, e)
          end
        end
      end


      def create_repo_if_missing(repo_name, index)
        logger.info "#{repo_name} (#{index + 1} out of #{@repos.length})"

        repo = hosting.read_repo(repo_name)
        if (repo.nil?)
          logger.info "Creating repo #{repo_name}"
          repo = hosting.create_repo(repo_name, @opts[:create_opts] || {})
        else
          logger.debug "Repo #{repo_name} already exists."
        end

        return repo
      end


      def update_repo(repo, source_repo_local_root)
        # TODO: Can we save the `git push` by comparing the HEAD of both repos?
        logger.info "Updating #{repo.name} from #{source_repo_local_root}"
        git.set_remote(source_repo_local_root, repo.name, repo.url, {create: true})
        # git.push(source_repo_local_root, repo.name)
        git.command(source_repo_local_root, "git push #{repo.name}")
      end


      def on_error(repo_name, index, err)
        logger.error "#{err} (#{repo_name}).\n\n#{err.backtrace.join("\n\t")}"
      end


    end
  end
end
