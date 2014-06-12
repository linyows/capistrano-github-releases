require 'capistrano/all'
require 'capistrano/github/releases/version'
load File.expand_path('../../tasks/github_releases.rake', __FILE__)
