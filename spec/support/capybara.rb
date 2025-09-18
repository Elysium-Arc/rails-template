# frozen_string_literal: true

# Capybara configuration for system tests
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |options|
      options.add_argument('--disable-dev-shm-usage')
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-gpu')
      options.add_argument('--window-size=1400,1400')
    end
  end

  # Save screenshots on failure
  config.after(:each, type: :system) do |example|
    if example.exception
      meta = example.metadata
      filename = File.basename(meta[:file_path])
      line_number = meta[:line_number]
      screenshot_name = "screenshot-#{filename}-#{line_number}.png"
      screenshot_path = Rails.root.join("tmp/screenshots/#{screenshot_name}")

      page.save_screenshot(screenshot_path)
      puts "Screenshot saved to #{screenshot_path}"
    end
  end
end

# Set Capybara defaults
Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }
