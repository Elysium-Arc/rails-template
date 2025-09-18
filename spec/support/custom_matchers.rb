# frozen_string_literal: true

# Custom RSpec matchers

# Matcher for checking email format
RSpec::Matchers.define :be_a_valid_email do
  match do |actual|
    actual =~ URI::MailTo::EMAIL_REGEXP
  end

  failure_message do |actual|
    "expected #{actual} to be a valid email address"
  end
end

# Matcher for checking timestamp freshness
RSpec::Matchers.define :be_recent do |window = 1.minute|
  match do |actual|
    actual && actual > window.ago
  end

  failure_message do |actual|
    "expected #{actual} to be within #{window} of current time"
  end
end

# Matcher for hashid presence
RSpec::Matchers.define :have_a_valid_hashid do
  match do |actual|
    actual.hashid.present? && actual.hashid.is_a?(String)
  end

  failure_message do |actual|
    "expected #{actual.class} to have a valid hashid"
  end
end
