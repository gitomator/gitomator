require 'gitomator/hosting_provider/base'

module HostingProvider
  class GitHub < Gitomator::HostingProvider::Base

    def name
      :github
    end


    def create_repo(name, opts)
      return Gitomator::Gitom::Hosting::Repo.new(self.name(), :create_repo, {
        name: name,
        opts: opts
      })
    end

  end
end
