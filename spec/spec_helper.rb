require 'gitomator'
require "gitomator/Hosting_provider/github.rb"

def create_hosting_provider(provider)
  provider ||= ENV['GIT_HOSTING_PROVIDER']
  case provider
  when 'github'
    return HostingProvider::GitHub.new
  else
    raise "Cannot create hosting provider. Unknown provider '#{provider}'"
  end

end
