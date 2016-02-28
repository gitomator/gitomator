require 'spec_helper'

def _create_hosting_provider()
  return create_hosting_provider(ENV['GIT_HOSTING_PROVIDER'])
end


describe HostingProvider do

  before(:each) do
    @provider = create_hosting_provider(ENV['GIT_HOSTING_PROVIDER'])
  end


  it "should not be nil" do
    expect(@provider).not_to be_nil
  end


  it "create_repo should return a Gitom object" do
    repo = "test-repo" + Time.now.to_i.to_s
    opts = {'foo' => rand().to_s}
    expect(@provider.create_repo(repo, opts)).to be_a_kind_of(Gitomator::Gitom::Base)
  end


  it "should be able to replay create_repo Gitom" do
    repo = "test-repo" + Time.now.to_i.to_s
    opts = {'foo' => rand().to_s}

    gitom = @provider.create_repo(repo, opts)

    expect(@provider).to receive(:create_repo).with(repo, opts)
    @provider.replay_gitom(gitom)
  end

end
