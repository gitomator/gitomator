module Gitomator
  module ServiceProvider
    class GitShell

      def clone(repo_url, local_repo_root, opts)
        _run_command("git clone #{repo_url} #{local_repo_root}", opts = {})
      end

      def init(local_repo_root, opts = {})
        Dir.mkdir(local_repo_root) unless Dir.exists?(local_repo_root)
        _run_git_command("init", local_repo_root)
      end

      def add(local_repo_root, path, opts={})
        _run_git_command("add #{path}", local_repo_root, opts)
      end

      def commit(local_repo_root, message, opts={})
        cmd = "commit -m \"#{message.gsub('"', '\\\"')}\""
        _run_git_command(cmd, local_repo_root, opts)
      end

      def checkout(local_repo_root, branch, opts)
        cmd = "checkout #{opts.has_key?('-b') ? '' : '-b'} #{branch}"
        _run_git_command(cmd, local_repo_root, opts)
      end

      def set_remote(local_repo_root, remote, url, opts)
        cmd = "remote #{opts[:create] ? 'add' : 'set-url'} #{remote} #{url}"
        opts.delete :create
        _run_git_command(cmd, local_repo_root, opts)
      end

      def push(local_repo_root, remote, opts)
        raise "Unsupported"
      end


      def command(local_repo_root, command)
        _run_git_command(command, local_repo_root, opts = {})
      end

      #=====================================================================


      def _run_command(cmd, opts = {})
        system({}, cmd, opts)
      end

      def _run_git_command(cmd, local_repo_root, opts = {})
        opts[:chdir] = local_repo_root
        unless cmd.strip.start_with? 'git'
          cmd = 'git ' + cmd
        end
        _run_command(cmd, opts)
      end

    end
  end
end
