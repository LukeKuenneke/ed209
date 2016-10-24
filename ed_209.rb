require 'httparty'
require 'byebug'
require 'octokit'
require 'shellwords'
require 'open3'

# https://youtu.be/A9l9wxGFl4k
class Ed209
  WORKING_DIR = '/tmp/'.freeze
  @github_username = ''
  @github_password = ''
  @github_auth = nil
  @ruby_project_urls = []

  def credentials
    print 'Please enter Github username: '
    @github_username = gets.chomp

    print 'Please enter Github password: '
    @github_password = gets.chomp

    @github_auth = Octokit::Client.new(login: @github_username,
                                       password: @github_password)
  end

  def ruby_project_urls
    HTTParty.get('https://api.github.com/search/repositories?q=+language:ruby' \
    '&sort=stars&order=asc').parsed_response['items'].each do |item|
      @ruby_project_urls = [] unless @ruby_project_urls
      @ruby_project_urls << {
        url: item['html_url'],
        full_name: item['full_name']
      }
    end
  end

  def process_projects
    @ruby_project_urls.each do |project|
      # Fork
      # forked_project = fork_project(project)

      # Clone
      # clone_local(forked_project)

      # Rubocop
      # run_rubocop(forked_project)

      # Commit
      # commit(forked_project)

      # Push
      # push(forked_project)

      # Create PR
      # create_pr(forked_project)

      # Delete
      # delete_local_code(forked_project)
    end
  end

  def run
    credentials
    ruby_project_urls
    process_projects
  end
end

main = Ed209.new
main.run
