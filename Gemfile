source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2", ">= 8.0.2.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
# gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Pagination
gem "pagy", "~> 9.3"

# Audit Active Record models
gem "audited"

# Rate limiting and throttling middleware
gem "rack-attack"

# Automatic eager loading of Active Record associations
gem "goldiloader"

# Filter using Ransack
gem "ransack"

# Pry as a console replacement
gem "pry", "~> 0.15.0"

# Simple Forms
gem "simple_form"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # ActiveRecord Doctor: Identify Database Issues
  gem "active_record_doctor"

  # Use RSpec for tests [https://rspec.info/]
  gem "byebug", platforms: [ :mri, :windows ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # letter_opener: Preview email in the browser
  gem "letter_opener"

  # Eliminate N+1 queries in Active Record
  gem "bullet"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

  # Shoulda Matchers for RSpec
  gem "shoulda-matchers", "~> 6.0"

  gem "rspec-rails", "~> 8.0.0"
end

# Tailwind CSS integration for Ruby
gem "tailwindcss-ruby", "~> 4.1.13"

# Tailwind CSS integration for Ruby on Rails
gem "tailwindcss-rails", "~> 4.3"

# Turbo Streams enhancements and utilities
gem "turbo_power", "~> 0.7.0"

# JavaScript bundling for Rails using esbuild, rollup, or webpack
gem "jsbundling-rails", "~> 1.3.1"

# ViewComponent framework for building reusable, testable & encapsulated view components
gem "view_component"

# Faker for generating fake data
gem "faker"

gem "factory_bot", "~> 6.5"
