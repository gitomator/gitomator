module Gitomator

  class Gitom

    attr_reader :service, :provider, :action, :data

    def initialize(service, provider, action, data)
      @service = service
      @provider = provider
      @action = action
      @data = data
    end

  end

end
