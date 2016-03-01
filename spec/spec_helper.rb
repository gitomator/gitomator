require 'gitomator'
require "gitomator/service/hosting/service"
require "gitomator/service/hosting/provider/github"
require "gitomator/service/hosting/provider/local"

require "gitomator/service/git/service"
require "gitomator/service/git/provider/shell"

require 'fileutils'

def create_hosting_service(provider_name)
  provider_name ||= ENV['GIT_HOSTING_PROVIDER']
  case provider_name
  when 'github'
    return Gitomator::Service::Hosting::Service.new (
      Gitomator::Service::Hosting::Provider::GitHub.new(
        ENV['GITHUB_ACCESS_TOKEN'], {org: ENV['GITHUB_TEST_ORG']}
      ))
  when 'local'
    git_provider = Gitomator::Service::Git::Provider::Shell.new()
    return Gitomator::Service::Hosting::Service.new (
      Gitomator::Service::Hosting::Provider::Local.new(git_provider, Dir.mktmpdir())
    )
  else
    raise "Cannot create hosting provider. Unknown provider '#{provider}'"
  end
end


def cleanup_hosting_service(service)
  case service.provider.name.to_s
  when 'github'
    # ...
  when 'local'
    puts "rm -rf #{service.provider.local_dir} ..."
    FileUtils.rm_rf(service.provider.local_dir)
  else
    raise "Cannot cleanup hosting provider. Unknown provider '#{service.provider.name}'"
  end
end
