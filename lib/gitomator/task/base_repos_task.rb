require 'gitomator/task'

module Gitomator
  module Task
    class BaseReposTask < Gitomator::BaseTask

      attr_reader :local_dir  # String or nil
      attr_reader :repos      # Array<String>

      #
      # @param context [Gitomator::Context]
      # @param auto_marker_config [Gitomator::Classroom::Config::AutoMarker] Parsed configuration object (TODO: Implement it as a subclass of Gitomator::Classroom::Assignment)
      # @param local_dir [String] A local directory where the repos will be (or have been) cloned.
      #
      def initialize(context, repos, local_dir=nil)
        super(context)
        unless local_dir.nil?
          raise "No such directory #{local_dir}" unless Dir.exists? local_dir
        end
        @local_dir = local_dir
        @repos = repos
        @blocks    = { :before => [], :after => [] }
      end



      def run()
        @blocks[:before].each {|b| self.instance_exec(&b) }

        repo2result, repo2error = {}, {}

        repos.each_with_index do |repo, index|
          logger.debug "#{repo} (#{index + 1} out of #{repos.length})"
          begin
            repo2result[repo] = process_repo(repo, index)
          rescue => e
            process_repo_error(repo, index, e)
            repo2error[repo] = e
          end
        end

        @blocks[:after].each {|b| self.instance_exec(repo2result, repo2error, &b) }
      end



      #
      # You need to override this method!
      #
      # @param repo [String] The name of the repo
      # @return Object (Optionally) return a result that can be used after processing all repos
      #
      def process_repo(repo, index)
        raise "Unimplemented"
      end

      #
      # Override this to provide custom error handling
      #
      def process_repo_error(repo, index, error)
        logger.error "#{repo} : #{error}\n#{error.backtrace.join("\n\t")}"
      end


      #
      # Inject a block that will run before processing any repos.
      # The blocks takes no arguments, and doesn't (need to) return any specific value.
      #
      def before_processing_any_repos(&block)
        @blocks[:before].push block
      end

      #
      # Inject a block that will run after all repos have been processed.
      #
      # @yield [result2mark, repo2error]
      # @yieldparam [Hash<String,Object>] repo2result
      # @yieldparam [Hash<String,Error>]  repo2error
      #
      def after_processing_all_repos(&block)
        @blocks[:after].push block
      end



    end
  end
end
