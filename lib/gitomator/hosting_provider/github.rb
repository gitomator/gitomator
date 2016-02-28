require 'gitomator/hosting_provider/base'
require 'gitomator/model/hosting/repo'

module HostingProvider
  class GitHub < Gitomator::HostingProvider::Base

    def name
      :github
    end


    #
    # @return Gitomator::Gitom::Base instance
    #
    def create_repo(name, opts)
      return Gitomator::Gitom::Hosting::Repo.new(self.name(), :create_repo, {
        name: name,
        opts: opts
      })
    end


    #
    # @return Gitomator::Model::Repo
    #
    def read_repo(name)
      return Gitomator::Model::Hosting::Repo.new(name, 'http://fake.clone/url.git', {})
    end



  end
end
