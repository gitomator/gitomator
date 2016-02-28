require 'gitomator'
require "gitomator/service/hosting/github"

def create_hosting_provider(provider)
  provider ||= ENV['GIT_HOSTING_PROVIDER']
  case provider
  when 'github'
    return Gitomator::Service::Hosting::GitHub.new
  else
    raise "Cannot create hosting provider. Unknown provider '#{provider}'"
  end

end
