
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "codeship_migrate_to_github_app/version"

Gem::Specification.new do |spec|
  spec.name          = "codeship_migrate_to_github_app"
  spec.version       = CodeshipMigrateToGithubApp::VERSION
  spec.authors       = ["Codeship Engineering"]
  spec.email         = ["codeship-engineering@cloudbees.com"]

  spec.summary       = "Migrate your Codeship Projects from legacy Github services to Codeship's Github App"
  spec.description   = "Migrate your Codeship Projects from legacy Github services to Codeship's Github App"
  spec.homepage      = "https://github.com/codeship/codeship_migrate_to_github_app"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|assets)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = "codeship_migrate_to_github_app"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.4.2"
  spec.add_development_dependency "pry-byebug", "~> 3.6.0"

  spec.add_dependency "thor", "~> 0.20.0"
  spec.add_dependency "http", "~> 3.3.0"
end
