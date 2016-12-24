# Gitomator

_Gitomator_ is a set of command-line tools for batch operations on hosted Git repositories.      

It was built to help software educators use tools like [GitHub](https://github.com) or [Travis CI](http://travis-ci.com) in their classroom, and here are some of the tasks it can help you with:

 * Create, clone and update repos
 * Create teams and update team memberships
 * Set access permissions
 * Enable/disable CI


Think of Gitomator as a _Swiss army knife for your GitHub organization_.

## Dependencies

 * [Ruby](https://www.ruby-lang.org/en/downloads/) (Gitomator is developed and tested on version 2.2)
 * [Ruby Gems](https://rubygems.org/pages/download)


## Installation

```sh
gem install gitomator
```


## Configure Credentials

Create the `.gitomator` configuration file *in your home directory* with your credential information:

```ruby
hosting:
  provider: github
  access_token: YOUR-GITHUB-ACCESS-TOKEN
  organization: YOUR-GITHUB-ORGANIZATION

ci:
  provider: travis_pro
  access_token: YOUR-TRAVIS-CI-ACCESS-TOKEN
  github_organization: YOUR-GITHUB-ORGANIZATION
```

 >  * You can read more about how to [create an access token on GitHub](https://github.com/blog/1509-personal-api-tokens).
 >  * If you don't use Travis CI, feel free to omit the `ci` configuration
 >  * You can specify a different path (other than `~/.gitomator`) for you configuration file, by setting the `GITOMATOR_CONTEXT` environment variable.
 >  * **Important:** Keep your credentials safe!      
      The `.gitomator` file is local to your machine, and should *not* be committed to version control.

## Examples

Let's see a few basic usage examples.

### Create repos

You can create a bunch of empty repos in your organization, by creating the following [YAML](https://en.wikipedia.org/wiki/YAML) file:

```ruby
repos:
 - repo_01
 - repo_02
 - repo_03
```

And running the following command:

```sh
gitomator-make-repos PATH-TO-YAML-FILE
```

 > You can change the YAML file and re-run the `gitomator-make-repos`, Gitomator will create repos that are missing.


If you want the repos to be created with initial starter code, you could add the `source_repo` field to the YAML file:

```ruby
source_repo: name_of_some_repo_in_your_organization

repos:
 - repo_01
 - repo_02
 - repo_03
```

 > * When Gitomator creates the repositories, it will push all the commits from the specified repo.
 > * If you are new to GitHub you may want to read about [the difference between forking and cloning-then-pushing](https://education.github.com/guide/repository_setup).


You can also specify various properties of created repositories, by adding the `repo_properties` field to the YAML file:

```ruby
source_repo: name_of_some_repo_in_your_organization

repo_properties:
  description: "A short description"
  homepage: "http://example.com"
  private: true
  has_issues: true
  has_wiki: false
  has_downloads: false
  default_branch: master

repos:
 - repo_01
 - repo_02
 - repo_03
```

### Update repos

You can update repos by updating the source repo (i.e. the repo that contains the starter code) and then run `gitomator-make-repos` with the `-u` option:

```sh
gitomator-make-repos -u PATH-TO-YAML-FILE
```

 > * Such a batch update is only possible when all repos have the same commit history.
 > * You can run `gitomator-make-repos` with `--help` for more information.


### Manage Access Permissions

You can specify who gets which permission to which repo in (the `repos` section
of) the same YAML file we've been using:

```ruby
repos:
 - repo_01 : user_01
 - repo_02 : user_02
 - repo_03 : [user_03, user_04]
```

And run:

```sh
gitomator-make-access-permissions PATH-TO-YAML-FILE
```

#### Users vs. Teams

You can use the `-p` option to specify whether the names in the YAML files refer
to users or teams. The following values are accepted:

 * `user`  - Names in the YAML file refer to users (this is the default)
 * `team`  - Names in the YAML file refer to teams
 * `mixed` - Let Gitomator figure out which name refers to a team and which refers to a user.


#### Read vs. Write

By default, Gitomator gives the specified users/teams read permission,
but you can specify otherwise in the YAML file:

```ruby
repos:
 - repo_01 : {user_01: write}
 - repo_02 : [{user_02: write}, user_07]
 - repo_03 : [team_01, {admin_01: write}]
```


### Clone repos

You can clone repos to your local machine using the `gitomator-clone-repos` command:

```sh
gitomator-clone-repos PATH-TO-YAML-FILE LOCAL-DIR
```

 > The YAML file has the same format as expected by the `gitomator-clone-repos` command.


### Manage teams

You can create teams and update team memberships with the `gitomator-make-teams` command,
which takes a YAML of the following format:

```ruby
team_01:
 - user_01
 - user_02
 - user_03

team_02:
 - user_01
 - user_07
```

When you run `gitomator-make-teams`, Gitomator will:
 * Create all missing teams (in your GitHub organization)
 * Add all missing team memberships

 > Users who are not yet members of your GitHub organization, will automatically
   get an email invite to join.
