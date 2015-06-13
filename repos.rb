class Repos

  def self.set_repo_names(repo_names=[])
    @@repo_names = repo_names
  end

  def self.update

    puts "Updating Repos..."

    github_repos = []
    @@repo_names.each do |repo_name|
      repo = Github.new user: 'erichoracek', repo: repo_name, login: 'erichoracek', password: ENV['GITHUB_PASSWORD']
      github_repos << repo.repos
    end

    repos = []
    github_repos.each do |github_repo|
      repo = github_repo.get
      repo_hash = repo.to_hash
      puts "Updated repo: " + repo_hash["name"] + " [ watchers : " + repo_hash["watchers"].to_s + " ]"
      repos << repo_hash
    end

    # Sort repos by number of watchers
    repos.sort { |repo1, repo2| repo1[:watchers] <=> repo2[:watchers] }

    # Place updated repos into the cache
    Sinatra::Application.settings.cache.set(:repos, repos)

    puts "Done Updating Repos"

  end

  def self.all
    return Sinatra::Application.settings.cache.get(:repos)
  end

end
