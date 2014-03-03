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
    set :ask_release, false

    set :username, -> {
      username = `git config --get user.name`.strip
      username = `whoami`.strip unless username
      username
    }

    set :release_tag, -> {
      Time.now.strftime('release-%Y%m%d-%H%M')
    }

    set :release_title, -> {
      default_title = nil

      run_locally do
        begin
          pull_request = Octokit.pull(fetch(:github_repo), fetch(:pull_request_id))
          default_title = pull_request.title
        rescue => e
          error e.message
          default_title = fetch(:release_tag)
        end
      end

      if fetch(:ask_release)
        title = HighLine.new.ask("Release Title? [default: #{default_title}]")
        title = default_title if title.empty?
        title
      else
        default_title
      end
    }

    set :release_body, -> {
      pull_req = "pull request: #{fetch(:github_repo)}##{fetch(:pull_request_id)}"

      if fetch(:ask_release)
        body = HighLine.new.ask("Release Comment? [default: #{pull_req}]")
        "#{body + "\n" unless body.empty?}#{pull_req}"
      else
        pull_req
      end
    }

    set :pull_request_id, -> {
      id = nil

      run_locally do
        merge_comment = capture "git log | grep 'Merge pull request' | head -n 1"
        id = merge_comment.match(/#(\d+)/)[1].to_i
      end

      id
    }

    set :release_comment, -> {
      url = "#{fetch(:github_releases_path)}/#{fetch(:release_tag)}"

      <<-MD.gsub(/^ {6}/, '').strip
        This change was deployed to production :octocat:
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

    desc 'GitHub authentication'
    task :authentication do
      run_locally do
        begin
          Octokit.configure do |c|
            c.access_token = fetch(:github_token)
          end

          rate_limit = Octokit.rate_limit!
          info 'Exceeded limit of the GitHub API request' if rate_limit.remaining.zero?
          debug "#{rate_limit}"
        rescue Octokit::NotFound
          # No rate limit for white listed users
        rescue => e
          error e.message
        end
      end
    end

    desc 'Create new release note'
    task create: :authentication do
      run_locally do
        begin
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
          error e.message
          invoke 'github:git:create_tag_and_push_origin'
        end
      end
    end

    desc 'Add comment for new release'
    task add_comment: :authentication do
      run_locally do
        begin
          Octokit.add_comment(
            fetch(:github_repo),
            fetch(:pull_request_id),
            fetch(:release_comment)
          )
        rescue => e
          error e.message
        end
      end
    end
  end

  namespace :git do
    desc 'Create tag for new release and push to origin'
    task :create_tag_and_push_origin do
      message = "#{fetch(:release_title)} by #{fetch(:username)}\n"
      message += "#{fetch(:github_repo)}##{fetch(:pull_request_id)}"

      run_locally do
        execute :git, :tag, '-am', "#{message}", "#{fetch(:release_tag)}"
        execute :git, :push, :origin, "#{fetch(:release_tag)}"
      end
    end
  end
end
