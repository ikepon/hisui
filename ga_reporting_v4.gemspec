$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ga_reporting_v4/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ga_reporting_v4"
  s.version     = GaReportingV4::VERSION
  s.authors     = ["ikepon"]
  s.email       = ["tatsuyanoheya@gmail.com"]
  s.homepage    = "https://github.com/ikepon/ga_reporting_v4"
  s.summary     = "Access the Google Analytics Reporting API v4 with Ruby"
  s.description = "Access the Google Analytics Reporting API v4 with Ruby"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 4.1.0"
  s.add_dependency "oauth2"
  s.add_dependency "google-api-client"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "dotenv"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"
end
