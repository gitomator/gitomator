require 'spec_helper'


describe Gitomator::Service::Hosting::Service do

  before(:each) do
    @hosting = create_hosting_service(ENV['GIT_HOSTING_PROVIDER'])
  end

  after(:each) do
    cleanup_hosting_service(@hosting)
  end


  it "should not be nil" do
    expect(@hosting).not_to be_nil
  end


  it "create_repo should return a repo model-object" do
    repo = "test-repo-#{(Time.now.to_f * 1000).to_i}"
    expect(@hosting.create_repo(repo, {})).to be_a_kind_of(Gitomator::Model::Hosting::Repo)
  end


  it "read_repo should return a repo model-object" do
    repo = @hosting.create_repo("test-repo-#{(Time.now.to_f * 1000).to_i}", {})
    expect(@hosting.read_repo(repo.name)).to be_a_kind_of(Gitomator::Model::Hosting::Repo)
  end

  it "read_repo should return nil when repo doesn't exist" do
    repo = "non-existing-#{(Time.now.to_f * 1000).to_i}"
    expect(@hosting.read_repo(repo)).to be_nil
  end

  it "delete_repo should delete a repo" do
    repo_name = "test-repo-#{(Time.now.to_f * 1000).to_i}"
    @hosting.create_repo(repo_name, {})
    @hosting.delete_repo(repo_name)
    expect(@hosting.read_repo(repo_name)).to be_nil
  end

  it "rename_repo should work properly" do
    repo_name1 = "test-repo-#{(Time.now.to_f * 1000).to_i}"
    repo_name2 = 'new-' + repo_name1

    @hosting.create_repo(repo_name1, {})
    @hosting.rename_repo(repo_name1, repo_name2)

    expect(@hosting.read_repo(repo_name1)).to be_nil
    expect(@hosting.read_repo(repo_name2)).to_not be_nil
  end


end
