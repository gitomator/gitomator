require 'gitomator'
require 'gitomator/exceptions'

module Gitomator
  class BaseService

    attr_reader :provider

    def initialize(provider, opts = {})
      @provider = provider
      @blocks  = { :before => [], :after => [], :error => [] }
    end

    #---------------------------------------------------------------------------
    # Inject blocks that do pre/post processing (e.g. logging)
    # Note: The blocks are bound to the service instance (i.e. in the block,
    #   self refers to the service instance)

    #
    # @param block [ Proc (String method_name, Array<Object> args) => nil ]
    #
    def before_each_service_call(&block)
      @blocks[:before].push block
    end

    #
    # @param block [ Proc (String method_name, Array<Object> args, Object result) => nil ]
    #
    def after_each_service_call(&block)
      @blocks[:after].push block
    end

    #
    # @param block [ Proc (String method_name, Array<Object> args, Error error) => nil ]
    #
    def on_service_call_error(&block)
      @blocks[:error].push block
    end

    #---------------------------------------------------------------------------


    def service_call(method, *args)
      result = nil
      @blocks[:before].each {|block| self.instance_exec(method, args, &block) }

      begin
        if provider.respond_to?(method)
          result = @provider.send(method, *args)
        else
          raise Gitomator::Exception::UnsupportedProviderMethod.new(@provider, method)
        end
      rescue Exception => e
        @blocks[:error].each {|block| self.instance_exec(method, args, e, &block) }
        raise e
      end

      @blocks[:after].each {|block| self.instance_exec(method, args, result, &block) }
      return result
    end


  end
end
