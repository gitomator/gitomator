require 'gitomator'


module Gitomator
  class BaseTask

    attr_accessor :logger
    attr_reader :context

    #
    # @param context [Gitomator::Context]
    #
    def initialize(context)
      @context = context
    end


    #
    # Subclasses should override this method
    #
    def run
      raise "Unimplemented"
    end


    def logger
      @logger ||= Gitomator::Util::create_logger()
    end

    def git
      context.git
    end

    def hosting
      context.hosting
    end

    def ci
      context.ci
    end


  end
end
