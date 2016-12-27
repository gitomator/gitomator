source 'https://rubygems.org'

# Specify your gem's dependencies in gitomator.gemspec
gemspec

#
# FIXME: The whole point is to be able to plug-in different providers (where the
#    core project is light, and doesn't know/care/depends on any specific provider).
#    I still don't know of a clean way to do that in Ruby, so for now let's add
#    gitomator-github and gitomator-travis as dependencies...
#
gem 'gitomator-github', :git => 'git@github.com:Gitomator/gitomator-github.git'
gem 'gitomator-travis', :git => 'git@github.com:Gitomator/gitomator-travis.git'
