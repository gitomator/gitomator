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
      @services = {}
    end

    #
    # @param service [Symbol] The service's name.
    # @param block [Proc<Hash> -> Object] Given a config, create a service object.
    #
    def register_service_factory(service, &block)
      @service2factory[service] = block

      # Create a lazy-loader getter for the service
      unless self.respond_to? service
        self.class.send(:define_method, service) do
          @services[service] ||= @service2factory[service].call(@config[service.to_s] || {})
        end
      end
    end

    def create_service(service)
      raise "Missing service, #{service}" unless @service2factory.has_key? service
      return @service2factory[service].call(@config[service.to_s] || {})
    end

  end



  class Context < BaseContext



    #===========================================================================
    # Static factory methods ...

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
      register_service_factory :git do |_|
        Gitomator::Service::Git::Service.new(Gitomator::Service::Git::Provider::Shell.new)
      end

      # Local-file-system hosting service
      register_service_factory :hosting do |hosting_config|
        create_default_hosting_service(hosting_config)
      end

    end

    #=========================================================================
    # Private helper methods


    def create_default_hosting_service(config)
      require 'tmpdir'
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
