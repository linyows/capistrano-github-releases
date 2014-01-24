require 'octokit'
require 'dotenv'
require 'highline'

Dotenv.load

module Dotenv
  def self.add(key_value, filename = nil)
    filename = File.expand_path(filename || '.env')
    f = File.open(filename, File.exists?(filename) ? 'a' : 'w')
    f.puts key_value
    key, value = key_value.split('=')
    ENV[key] = value
  end
end

namespace :github do
  namespace :releases do
    set :username, -> {
      username = `git config --get user.name`.strip
      username = `whoami`.strip unless username
      username
    }

    set :github_username, -> {
      if ENV['GITHUB_USERNAME'].nil?
        username = HighLine.new.ask("GitHub Username? [default: #{fetch(:username)}]")
        Dotenv.add "GITHUB_USERNAME=#{username}"
      else
        ENV['GITHUB_USERNAME']
      end
    }

    set :release_title, -> {
      begin
        pull_request = Octokit.pull(fetch(:github_repo), fetch(:pull_request_id))
        default_title = pull_request.title
      rescue => e
        puts e
        default_title = fetch(:release_tag)
      end
      title = HighLine.new.ask("Release Title? [default: #{default_title}]")
      title = default_title if title.empty?
      title
    }

    set :release_body, -> {
      pull_req = "pull request: #{fetch(:github_repo)}##{fetch(:pull_request_id)}"
      body = HighLine.new.ask("Release Comment? [default: #{pull_req}]")
      "#{body + "\n" unless body.empty?}#{pull_req}"
    }

    set :release_tag, -> {
      Time.now.strftime('release-%Y%m%d-%H%M')
    }

    set :pull_request_id, -> {
      merge_comment = `git log | grep 'Merge pull request' | head -n 1`
      merge_comment.match(/#(\d+)/)[1].to_i
    }

    set :release_comment, -> {
      url = "#{fetch(:github_releases_path)}/#{fetch(:release_tag)}"
      <<-MD.gsub(/^ {6}/, '').strip
        I deployed this with production environment and created a release tag. :octocat:
        #{fetch(:release_title)}: [#{fetch(:release_tag)}](#{url})
      MD
    }

    set :github_token, -> {
      if ENV['GITHUB_PERSONAL_ACCESS_TOKEN'].nil?
        token = HighLine.new.ask('GitHub Personal Access Token?')
        Dotenv.add "GITHUB_PERSONAL_ACCESS_TOKEN=#{token}"
      else
        ENV['GITHUB_PERSONAL_ACCESS_TOKEN']
      end
    }

    set :github_repo, -> {
      repo = "#{fetch(:repo_url)}"
      repo.match(/([\w-]+\/[\w-]+)\.git$/)[1]
    }

    set :github_releases_path, -> {
      "#{Octokit.web_endpoint}#{fetch(:github_repo)}/releases/tag"
    }

    set :github_authentication, -> {
      Octokit.configure do |c|
        c.login = fetch(:github_username)
        c.access_token = fetch(:github_token)
      end
    }

    desc 'Create new release note.'
    task :create do
      begin
        fetch(:github_authentication)

        Octokit.create_release(
          fetch(:github_repo),
          fetch(:release_tag),
          name: fetch(:release_title),
          body: fetch(:release_body),
          target_commitish: 'master',
          draft: false,
          prerelease: false
        )
      rescue => e
        puts e
        invoke 'github:git:create_tag_and_push_origin'
      end
    end

    desc 'Add comment for new release.'
    task :add_comment do
      begin
        fetch(:github_authentication)

        Octokit.add_comment(
          fetch(:github_repo),
          fetch(:pull_request_id),
          fetch(:release_comment)
        )
      rescue => e
        puts e
      end
    end
  end

  namespace :git do
    desc 'Create tag for new release and push to origin.'
    task :create_tag_and_push_origin do
      message = "#{fetch(:release_title)} by #{fetch(:username)}\n"
      message += "#{fetch(:github_repo)}##{fetch(:pull_request_id)}"
      `git tag -am "#{message}" #{fetch(:release_tag)}`
      `git push origin #{fetch(:release_tag)}`
    end
  end
end
