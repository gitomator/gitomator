require 'gitomator'
require 'gitomator/service/git/service'
require 'gitomator/service/git/provider/shell'

require 'gitomator/service/hosting/service'

require 'gitomator/service/ci/service'



module Gitomator

  #
  # Register service-factories, and create services.
  #
  class BaseContext


    def initialize(config = {})
      @config = config
      @service2factory = {}
    end

    #---------------------------------------------------------------------------

    #
    # @param service [Symbol] One of :logger, :git, :hosting, :ci
    # @param block [Proc([Hash] config) -> [Object] service]
    #
    def register_service_factory(service, &block)
      @service2factory[service] = block
    end

    def create_service(service)
      raise "Missing service, #{service}" unless @service2factory.has_key? service
      return @service2factory[service].call(@config[service.to_s] || {})
    end

    #---------------------------------------------------------------------------
    # Public API

    def register_logger_factory(&block)
      register_service_factory(:logger, &block)
    end

    # Lazy-loading getter
    def logger
      @logger ||= create_service(:logger)
    end

  end



  class Context < BaseContext

    #===========================================================================

    class << self
      private :new
    end

    #
    # @param config_file [String/File] - YAML configuration file.
    #
    def self.from_file(config_file)
      return from_hash(Gitomator::Util.load_config(config_file))
    end

    #
    # @param config [Hash] - Configuration data (e.g. parsed from a YAML file)
    #
    def self.from_hash(config)
      return new(config)
    end

    #===========================================================================

    def initialize(config)
      super(config)

      # Regsiter default service factories ...

      register_service_factory :logger do |logger_config|
        create_default_logger(logger_config)
      end

      # Shell-based Git service
      register_service_factory :git do
        Gitomator::Service::Git::Service.new(Gitomator::Service::Git::Provider::Shell.new)
      end

      # Local-file-system hosting service
      register_service_factory :hosting do |hosting_config|
        create_default_hosting_service(hosting_config)
      end

    end

    #===========================================================================
    # Convenient wrappers for supported services ...

    # Service-factory registration

    def register_git_service_factory(&block)
      register_service_factory(:git, &block)
    end

    def register_hosting_service_factory(&block)
      register_service_factory(:hosting, &block)
    end

    def register_ci_service_factory(&block)
      register_service_factory(:ci, &block)
    end

    # Lazy-loading service getters

    def git
      @git ||= create_service(:git)
    end

    def hosting
      @hosting ||= create_service(:hosting)
    end

    def ci
      @ci ||= create_service(:ci)
    end


    #=========================================================================
    # Private helper methods


    def create_default_hosting_service(config)
      require "gitomator/service/hosting/provider/local"

      dir = config['dir'] || Dir.mktmpdir('Gitomator_')
      return Gitomator::Service::Hosting::Service.new (
        Gitomator::Service::Hosting::Provider::Local.new(git, dir)
      )
    end


    def create_default_logger(c)
      gem 'logger'; require 'logger'

      if c.nil?
        return Logger.new(STDOUT)
      end

      output = STDOUT
      case c['output']
      when nil
        output = STDOUT
      when 'STDOUT'
        output = STDOUT
      when 'STDERR'
        output = STDERR
      when 'NULL' || 'OFF'        # Write the dev/null (i.e. logging is off)
        output = File.open(File::NULL, "w")
      else
        output = File.open(c['output'], "a")
      end

      lgr = Logger.new(output)
      if c['level']
        lgr.level = Logger.const_get(c['level'])
      end
      return lgr
    end


  end
end
