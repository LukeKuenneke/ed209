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
      @ruby_project_urls ||= []
      @ruby_project_urls << {
        url: item['html_url'],
        full_name: item['full_name']
      }
    end
  end

  def fork_project(project)
    @github_auth.fork(project[:full_name])
  end

  def clone_local(project)
    command = 'cd ' + WORKING_DIR + '; mkdir ed209; cd ed209; git clone ' +
              project[:clone_url]
    system(command)
  end

  def run_rubocop(project)
    command = 'cd ' + WORKING_DIR + 'ed209/' + project[:name] + '&& rubocop -a'
    system(command)
  end

  def commit(project)
    command = 'cd ' + WORKING_DIR + 'ed209/' + project[:name] +
              '; git commit -a --author=\'' + @github_auth.user[:name] +
              ' <' + @github_auth.user[:email] +
              '>\' -m \'Rubocop auto-correct ed209: ' \
              'https://github.com/LukeKuenneke/ed209\''
    system(command)
  end

  def push(project)
    command = 'cd ' + + '; `git push https://' + @github_username + ':' +
              Shellwords.escape(@github_password) + '@' +
              project[:html_url].gsub('https://', '') + '.git`'
    system(command)
  end

  # def create_pr(project)
  # end

  def delete_local_code(project)
    exec('rm -rf ' + WORKING_DIR + 'ed209/' + project[:name])
  end

  def process_projects
    @ruby_project_urls.each do |project|
      # Fork
      forked_project = fork_project(project)

      # Clone
      clone_local(forked_project)

      # Rubocop
      run_rubocop(forked_project)

      # Commit
      commit(forked_project)

      # Push
      push(forked_project)

      # Create PR
      # create_pr(forked_project)

      # Delete
      delete_local_code(forked_project)
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
