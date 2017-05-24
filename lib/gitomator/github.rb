require "gitomator/github/version"

module Gitomator
  module GitHub


    def self.github_client_from_config(config = {})
      # Convert keys yo strings (to handle keys whose type is Symbol)
      config = config.map {|k,v| [k.to_s, v]} .to_h

      opts = {}

      if config['access_token']
        opts[:access_token]   = config['access_token']
      elsif config['username'] && config['password']
        opts[:login]          = config['username']
        opts[:password]       = config['password']
      elsif config['client_id'] && config['client_secret']
        opts[:client_id]      = config['client_id']
        opts[:client_secret]  = config['client_secret']
      else
        raise "Invalid GitHub hosting configuration - #{config}"
      end

      require 'octokit'
      return Octokit::Client.new(opts)
    end


  end
end
