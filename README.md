Capistrano Github-Releases
==========================

GitHub Releases tasks for Capistrano v3:

```sh
$ bundle exec cap production github:releases:create # Auto creation by last pull-request
$ bundle exec cap production github:releases:add_comment # Auto comment to last pull-request
```

[![Gem Version](https://badge.fury.io/rb/capistrano-github-releases.png)][gem]
[gem]: https://rubygems.org/gems/capistrano-github-releases

Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-github-releases'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install capistrano-github-releases
```

Usage
-----

Capfile:

```ruby
require 'capistrano/github/releases'
```

deploy/production.rb:

```ruby
after 'deploy:finishing', 'github:releases:create'
after 'deploy:finishing', 'github:releases:add_comment'
```

### Options

Set capistrano variables with `set name, value`.

Name            | Default                                              | Description
----            | -------                                              | -----------
ask_release     | false                                                | When true, asks for the release title and text
release_tag     | `Time.now.strftime('release-%Y%m%d-%H%M')`           | Create releases when git-tag name
release_comment | This change was deployed to production :octocat: ... | Pull requests to deploy report comment

### GitHub Enterprise

deploy.rb:

```ruby
Octokit.configure do |c|
  c.api_endpoint = 'http://your.enterprise.domain/api/v3'
  c.web_endpoint = 'http://your.enterprise.domain/'
end
```

Contributing
------------

1. Fork it ( http://github.com/linyows/capistrano-github-releases/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Authors
-------

- [linyows](https://github.com/linyows)

License
-------

The MIT License (MIT)
