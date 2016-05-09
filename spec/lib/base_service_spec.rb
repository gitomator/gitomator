require 'gitomator/service'

describe Gitomator::BaseService do


  #
  # An example of a class that extends the base-service.
  #
  class FooService < Gitomator::BaseService

    def foo
      service_call(__callee__)
    end

    def bar(arg1, arg2)
      service_call(__callee__, arg1, arg2)
    end

  end




  it "should forward service calls to the provider" do
    provider = Object.new
    service  = FooService.new(provider)

    expect(provider).to receive(:foo)
    service.foo()
  end


  it "should return the provider's result when making a service call" do
    provider = Object.new
    allow(provider).to receive(:foo) { 42 }

    service = FooService.new(provider)

    expect(service.foo()).to eq(42)
  end


  it "should pass arguments when forwarding service calls to the provider" do
    provider = Object.new
    service = FooService.new(provider)

    expect(provider).to receive(:bar).with("abc", 123)
    service.bar("abc", 123)
  end


  it "should raise error when a service call is not supported by a provider" do
    provider = Object.new
    service = FooService.new(provider)

    expect { service.bar("abc", 123) }.to raise_error(Gitomator::Exception::UnsupportedProviderMethod)
  end


end
