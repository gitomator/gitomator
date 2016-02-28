require 'spec_helper'

def _create_hosting_provider()
  return create_hosting_provider(ENV['GIT_HOSTING_PROVIDER'])
end


describe HostingProvider do
  it "should not be nil" do
    provider = _create_hosting_provider()
    expect(provider).not_to be_nil
  end
end
