# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Session, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'factory' do
    it 'creates a valid session' do
      session = build(:session)
      expect(session).to be_valid
    end

    it 'creates session with user' do
      session = create(:session)
      expect(session.user).to be_present
      expect(session.user).to be_a(User)
    end
  end

  describe 'attributes' do
    let(:session) { create(:session) }

    it 'has ip_address' do
      expect(session.ip_address).to be_present
    end

    it 'has user_agent' do
      expect(session.user_agent).to be_present
    end

    it 'tracks updated_at timestamp' do
      expect(session.updated_at).to be_present
    end
  end

  describe 'traits' do
    it 'creates recent session' do
      session = create(:session, :recent)
      expect(session.updated_at).to be_within(10.minutes).of(5.minutes.ago)
    end

    it 'creates idle session' do
      session = create(:session, :idle)
      expect(session.updated_at).to be_within(1.hour).of(12.hours.ago)
    end

    it 'creates old session' do
      session = create(:session, :old)
      expect(session.updated_at).to be_within(1.hour).of(2.days.ago)
    end
  end
end
