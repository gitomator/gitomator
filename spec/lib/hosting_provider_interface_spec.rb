require 'spec_helper'


describe Gitomator::Service::Hosting::Service do

  before(:each) do
    @hosting = create_hosting_service(ENV['GIT_HOSTING_PROVIDER'])
  end


  it "should not be nil" do
    expect(@hosting).not_to be_nil
  end


  it "create_repo should return a repo model-object" do
    repo = "test-repo" + Time.now.to_i.to_s
    opts = {'foo' => rand().to_s}
    expect(@hosting.create_repo(repo, opts)).to be_a_kind_of(Gitomator::Model::Hosting::Repo)
  end


  it "read_repo should return a repo model-object" do
    expect(@hosting.read_repo('test-repo')).to be_a_kind_of(Gitomator::Model::Hosting::Repo)
  end


end
