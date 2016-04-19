require 'gitomator'

require "gitomator/service/hosting"
require "gitomator/service_provider/hosting_local"

require "gitomator/service/git"
require "gitomator/service_provider/git_shell"

require 'fileutils'



describe Gitomator::ServiceProvider::HostingLocal do

  before(:all) do
    @git_provider = Gitomator::ServiceProvider::GitShell.new()
  end

  before(:each) do
    @local_dir = Dir.mktmpdir()
    @hosting = Gitomator::Service::Hosting.new (
      Gitomator::ServiceProvider::HostingLocal.new(@git_provider, @local_dir)
    )
  end

  after(:each) do
    FileUtils.rm_rf(@local_dir)
  end


  it "should not be nil" do
    expect(@hosting).not_to be_nil
  end


  it "create_repo should return a repo model-object" do
    repo = "test-repo-#{(Time.now.to_f * 1000).to_i}"
    expect(@hosting.create_repo(repo, {})).to respond_to(:name, :full_name, :url)
  end


  it "read_repo should return a repo model-object" do
    repo = @hosting.create_repo("test-repo-#{(Time.now.to_f * 1000).to_i}", {})
    expect(@hosting.read_repo(repo.name)).to respond_to(:name, :full_name, :url)
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

  it "update a repo's name" do
    name1 = "test-repo-#{(Time.now.to_f * 1000).to_i}"
    name2 = 'new-' + name1

    @hosting.create_repo(name1, {})
    @hosting.update_repo(name1, {name: name2})

    repo1 = @hosting.read_repo(name1)
    # If we ask for the old name, we can either get nil or the new repo
    # (e.g. GitHub automatically forwards the request to the new repo)
    expect(repo1.nil? || repo1.name == name2).to be true

    expect(@hosting.read_repo(name2)).to_not be_nil
  end


  # ------------------------------ TEAMS ---------------------------------------



  it "create team" do
    expect { @hosting.create_team("foo") } .to raise_error(
                                  Gitomator::Exception::UnsupportedProviderMethod)
  end

  it "read team" do
    expect { @hosting.read_team("foo") } .to raise_error(
                                  Gitomator::Exception::UnsupportedProviderMethod)
  end

  it "update team" do
    expect { @hosting.update_team("foo") } .to raise_error(
                                  Gitomator::Exception::UnsupportedProviderMethod)
  end

  it "delete team" do
    expect { @hosting.delete_team("foo") } .to raise_error(
                                  Gitomator::Exception::UnsupportedProviderMethod)
  end

end
