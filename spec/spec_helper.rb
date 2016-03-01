require 'gitomator'
require "gitomator/service/hosting/service"
require "gitomator/service/hosting/provider/github"
require "gitomator/service/hosting/provider/local"

def create_hosting_service(provider_name)
  provider_name ||= ENV['GIT_HOSTING_PROVIDER']
  case provider_name
  when 'github'
    return Gitomator::Service::Hosting::Service.new (
      Gitomator::Service::Hosting::Provider::GitHub.new())
  when 'local'
    return Gitomator::Service::Hosting::Service.new (
      Gitomator::Service::Hosting::Provider::Local.new(
        Gitomator::Service::Git::ShellBased.new,
        "/tmp/gitomator"
      ))
  else
    raise "Cannot create hosting provider. Unknown provider '#{provider}'"
  end

end
