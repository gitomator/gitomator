# Gitomator

Command-line tools for performing batch operations on hosted Git repos.      
For example:

 * Creating teams and updating team memberships
 * Creating (and updating) repos
 * Setting access permissions to repos
 * Enabling/disabling CI

 > Think of Gitomator as a _Swiss army knife for your GitHub organization_.

# Dependencies

 * [Ruby](https://www.ruby-lang.org/en/downloads/) (Gitomator is developed and tested on version 2.2)
 * [Ruby Gems](https://rubygems.org/pages/download)


# Installation

 Install Gitomator:

```
gem install gitomator
```

Create the `.gitomator` configuration file in your home directory:

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
