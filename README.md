 > **IMPORTANT:** All Gitomator projects are currently in pre-alpha stage, which means that:        
 >
 >  * Some parts are not implemented
 >  * API's may change significantly
 >  * There are not a lot of tests
 >


# Gitomator

This is the base library for all Gitomator projects.
It contains the following high-level, provider-agnostic service API's:

 * [`hosting`](lib/gitomator/service/hosting/service.rb) (ex: GitHub organization)
 * [`ci`](lib/gitomator/service/ci/service.rb) (ex: Travis CI)
 * [`git`](lib/gitomator/service/hosting/service.rb) (used for local Git operations)

The goals of the Gitomator library are:

 * Help software educators by providing a lightweight, general-purpose, reusable library.
 * Simplify automation tasks by providing high-level API's.
 * Portability - Gitomator allows you to run the same application with different providers.


For more details, you should probably take a look at https://github.com/Gitomator/gitomator-classroom


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Gitomator/gitomator.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
