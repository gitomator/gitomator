require 'gitomator'


module Gitomator


  #
  # Register service-factories, and create services.
  #
  class BaseContext

    #
    # @param config [Hash]
    #
    def initialize(config)
      @config = config
      @service2factory = {}
      @services = {}

      config.select { |_,v| v.is_a?(Hash) && v.has_key?('provider')}
        .each do |service, service_config|
          register_service(service.to_sym) do |config|
            self.send("create_#{config['provider']}_#{service}_service", config || {})
          end
        end

    end


    #
    # @param service [Symbol] The service's name.
    # @param block [Proc<Hash> -> Object] Given a config, create a service object.
    #
    def register_service(service, &block)
      @service2factory[service] = block

      # Create a lazy-loader getter for the service
      unless self.respond_to? service
        self.class.send(:define_method, service) do
          @services[service] ||= @service2factory[service].call(@config[service.to_s] || {})
        end
      end
    end

  end


  #=============================================================================


  class Context < BaseContext

    #
    # Convenience function to create Context instances from configuration files.
    # @param config_file [String/File] - YAML configuration file.
    #
    def self.from_file(config_file)
      return new(Gitomator::Util.load_config(config_file))
    end

    #---------------------------------------------------------------------------


    DEFAULT_CONFIG = {
      'git'     => { 'provider' => 'shell'},
      'hosting' => { 'provider' => 'local'}
    }

    def initialize(config={})
      super(DEFAULT_CONFIG.merge(config))
    end


    def create_local_hosting_service(config)
      require 'gitomator/service/hosting'
      require 'gitomator/service_provider/hosting_local'
      require 'tmpdir'

      dir = config['dir'] || Dir.mktmpdir('Gitomator_')
      return Gitomator::Service::Hosting.new (
        Gitomator::ServiceProvider::HostingLocal.new(git, dir)
      )
    end


    def create_shell_git_service(_)
      require 'gitomator/service/git'
      require 'gitomator/service_provider/git_shell'
      Gitomator::Service::Git.new(Gitomator::ServiceProvider::GitShell.new())
    end


    #---------------------------------------------------------------------------

    # Services from here onwards should have really been plug-ins.
    # Unfortuantely, I don't know of a clean way to do that in Ruby.


    def create_github_hosting_service(config)
      require 'gitomator/service/hosting'
      require 'gitomator/github/hosting_provider'

      return Gitomator::Service::Hosting.new (
        Gitomator::GitHub::HostingProvider.from_config(config))
    end


    def create_travis_ci_service(config)
      require 'gitomator/service/ci'
      require 'gitomator/travis/ci_provider'

      return Gitomator::Service::CI.new(
        Gitomator::Travis::CIProvider.from_config(config))
    end

    def create_travis_pro_ci_service(config)
      create_travis_ci_service(config)
    end


    def create_github_tagging_service(config)
      require 'gitomator/service/tagging'
      require 'gitomator/github/tagging_provider'

      return Gitomator::Service::Tagging.new (
        Gitomator::GitHub::TaggingProvider.from_config(config))
    end



  end
end
