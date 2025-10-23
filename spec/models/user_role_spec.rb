# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserRole, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:role) }
  end

  describe 'validations' do
    subject { build(:user_role) }

    it 'validates uniqueness of user_id scoped to role_id' do
      user = create(:user)
      role = create(:role)
      create(:user_role, user: user, role: role)
      duplicate = build(:user_role, user: user, role: role)
      expect(duplicate).to_not be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end
  end

  describe 'auditing' do
    it 'creates audit records on create' do
      expect {
        create(:user_role)
      }.to change { Audited::Audit.count }.by_at_least(1)
    end
  end
end
