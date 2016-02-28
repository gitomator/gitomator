require 'gitomator/gitom'

module HostingProvider
  class GitHub


    def create_repo(name, opts)
      return Gitomator::Gitom.new(:hosting, :github, :create_repo, {
        name: name,
        opts: opts
      })
    end



    def replay_gitom(gitom)
      _validate_gitom(gitom)
      self.send gitom.action, gitom.data[:name], gitom.data[:opts]
    end


    def _validate_gitom(gitom)
      raise "Invalid event" if gitom.nil?
      raise "Invalid service - '#{gitom.service}'" unless gitom.service == :hosting
      raise "Invalid provider - '#{gitom.provider}'" unless gitom.provider == :github
    end


  end
end
