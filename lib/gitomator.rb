require "gitomator/version"

module Gitomator

  module Util



    #
    # Given a config file (path to file, or an object that responds to :read),
    # do that ERB+YAML thing, and return a Hash.
    #
    # @param config [String/File]
    # @return Hash
    #
    def self.load_config(config)
      require 'erb'
      require 'yaml'

      if config.respond_to? :read
        YAML::load(ERB.new(config.read).result)
      else
        YAML::load(ERB.new(File.read(config)).result)
      end
    end



    def self.create_logger(config = {})
      gem 'logger'; require 'logger'

      if config.nil?
        return Logger.new(STDOUT)
      end

      output = STDOUT
      case config['output']
      when nil
        output = STDOUT
      when 'STDOUT'
        output = STDOUT
      when 'STDERR'
        output = STDERR
      when 'NULL' || 'OFF'        # Write the dev/null (i.e. logging is off)
        output = File.open(File::NULL, "w")
      else
        output = File.open(config['output'], "a")
      end

      lgr = Logger.new(output)
      if config['level']
        lgr.level = Logger.const_get(config['level'])
      end
      return lgr
    end



  end

end
