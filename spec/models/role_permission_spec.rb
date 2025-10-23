# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RolePermission, type: :model do
  describe 'associations' do
    it { should belong_to(:role) }
    it { should belong_to(:permission) }
  end

  describe 'validations' do
    subject { build(:role_permission) }

    it 'validates uniqueness of role_id scoped to permission_id' do
      role = create(:role)
      permission = create(:permission)
      create(:role_permission, role: role, permission: permission)
      duplicate = build(:role_permission, role: role, permission: permission)
      expect(duplicate).to_not be_valid
      expect(duplicate.errors[:role_id]).to be_present
    end
  end
end
