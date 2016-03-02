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
    name = "team-#{(Time.now.to_f * 1000).to_i}"
    team = @hosting.create_team(name)
    expect(team).to be_a_kind_of(Gitomator::Model::Hosting::Team)
    expect(team.name).to_not be name
  end


  it "create team and get it" do
    name = "team-#{(Time.now.to_f * 1000).to_i}"
    @hosting.create_team(name)
    team = @hosting.read_team(name)

    expect(team).to be_a_kind_of(Gitomator::Model::Hosting::Team)
    expect(team.name).to_not be name
  end

  it "delete_team should delete a team" do
    name = "team-#{(Time.now.to_f * 1000).to_i}"
    @hosting.create_team(name)
    @hosting.delete_team(name)
    expect(@hosting.read_team(name)).to be_nil
  end

  it "update a team's name" do
    name1 = "team-#{(Time.now.to_f * 1000).to_i}"
    name2 = 'new-' + name1

    @hosting.create_team(name1)
    @hosting.update_team(name1, {name: name2})

    team1 = @hosting.read_team(name1)
    # If we ask for the old name, we can either get nil or the new team
    expect(team1.nil? || team1.name == name2).to be true

    team2 = @hosting.read_team(name2)
    expect(team2).to be_a_kind_of(Gitomator::Model::Hosting::Team)
    expect(team2.name).to_not be name2
  end


end
