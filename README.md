Capistrano::Github::Releases
============================

[![Gem Version](https://badge.fury.io/rb/capistrano-github-releases.png)][gem]
[gem]: https://rubygems.org/gems/capistrano-github-releases

GitHub Releases tasks for Capistrano v3:

Installation
------------

Add this line to your application's Gemfile:

    gem 'capistrano-github-releases'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-github-releases

Usage
-----

Capfile:

```ruby
require 'capistrano/github/releases'
```

deploy/production.rb:

```ruby
after 'deploy:published', 'github:releases:create'
after 'deploy:published', 'github:releases:add_comment'
```


Contributing
------------

1. Fork it ( http://github.com/<my-github-username>/capistrano-github-releases/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
