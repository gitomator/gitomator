require 'fileutils'


module Gitomator
  module ServiceProvider
    # A hosting provider that manages repos in a directory on the local
    # file-system.
    class HostingLocal


      #-------------------------------------------------------------------------

      #
      # A small wrapper that takes a hash, and create an attr_accessor for
      # each hash key.
      # This is a temporary implementation, until we create proper model
      # objects (e.g. HostedRepo, Team, PullRequest, etc.)
      #
      class ModelObject
        def initialize(hash)
          hash.each do |key, value|
            setter = "#{key}="
            self.class.send(:attr_accessor, key) if !respond_to?(setter)
            send setter, value
          end
        end
      end

      #-------------------------------------------------------------------------


      attr_reader :local_dir, :local_repos_dir

      def initialize(git_service, local_dir, opts = {})
        @git         = git_service

        raise "Local directory doesn't exist, #{local_dir}" unless Dir.exist? local_dir
        @local_dir   = local_dir

        @local_repos_dir = File.join(@local_dir, opts[:repos_dir] || 'repos')
        Dir.mkdir @local_repos_dir unless Dir.exist? @local_repos_dir
      end

      #---------------------------------------------------------------------

      def name
        :local
      end


      def repo_root(name)
        File.join(local_repos_dir, name)
      end

      #---------------------------------------------------------------------

      def create_repo(name, opts)
        raise "Directory exists, #{repo_root(name)}" if Dir.exist? repo_root(name)
        @git.init(repo_root(name), opts)
        return ModelObject.new({
          :name => name, :full_name => name, :url => "#{repo_root(name)}/.git"
        })
      end


      def read_repo(name)
        if Dir.exist? repo_root(name)
          return ModelObject.new({
            :name => name, :full_name => name, :url => "#{repo_root(name)}/.git"
          })
        else
          return nil
        end
      end


      def update_repo(name, opts={})
        if opts[:name]
          _rename_repo(name, opts[:name])
        end
        return read_repo(name)
      end


      def delete_repo(name)
        if Dir.exist? repo_root(name)
          FileUtils.rm_rf repo_root(name)
        else
          raise "No such repo, '#{name}'"
        end
        return nil
      end


      def _rename_repo(old_name, new_name)
        raise "No such repo '#{old_name}'" unless Dir.exist? repo_root(old_name)
        FileUtils.mv repo_root(old_name), repo_root(new_name)
      end


    end
  end
end
