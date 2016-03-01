require 'gitomator'
require "gitomator/service/hosting/service"
require "gitomator/service/hosting/provider/github"
require "gitomator/service/hosting/provider/local"

require "gitomator/service/git/service"
require "gitomator/service/git/provider/shell_based"

def create_hosting_service(provider_name)
  provider_name ||= ENV['GIT_HOSTING_PROVIDER']
  case provider_name
  when 'github'
    return Gitomator::Service::Hosting::Service.new (
      Gitomator::Service::Hosting::Provider::GitHub.new())
  when 'local'
    git_provider = Gitomator::Service::Git::Provider::ShellBased.new()
    return Gitomator::Service::Hosting::Service.new (
      Gitomator::Service::Hosting::Provider::Local.new(git_provider,"/tmp/gitomator")
    )
  else
    raise "Cannot create hosting provider. Unknown provider '#{provider}'"
  end

end
