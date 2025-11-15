# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Permission, type: :model do
  describe 'associations' do
    it { should have_many(:role_permissions).dependent(:destroy) }
    it { should have_many(:roles).through(:role_permissions) }
    it { should belong_to(:resource).optional }
  end

  describe 'validations' do
    subject { build(:permission) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }

    context 'uniqueness' do
      before { create(:permission, name: 'users.create') }

      it 'validates uniqueness of name scoped to resource' do
        expect(build(:permission, name: 'users.create')).not_to be_valid
      end
    end

    it 'validates name format' do
      expect(build(:permission, name: 'invalid-name')).not_to be_valid
      expect(build(:permission, name: 'InvalidName')).not_to be_valid
      expect(build(:permission, name: 'valid_name')).to be_valid
      expect(build(:permission, name: 'users.create')).to be_valid
    end
  end

  describe 'scopes' do
    let!(:global_permission) { create(:permission, resource_type: nil, resource_id: nil) }
    let!(:scoped_permission) { create(:permission, :scoped) }

    describe '.global' do
      it 'returns only global permissions' do
        expect(Permission.global).to include(global_permission)
        expect(Permission.global).not_to include(scoped_permission)
      end
    end

    describe '.scoped_to' do
      it 'returns permissions scoped to a resource' do
        user = User.create!(email_address: 'test@example.com', password: 'password123')
        permission = create(:permission, resource_type: 'User', resource_id: user.id)

        expect(Permission.scoped_to(user)).to include(permission)
        expect(Permission.scoped_to(user)).not_to include(global_permission)
      end
    end

    describe '.by_resource_type' do
      it 'returns permissions filtered by resource type' do
        user_permission = create(:permission, resource_type: 'User')

        expect(Permission.by_resource_type('User')).to include(user_permission)
        expect(Permission.by_resource_type('User')).not_to include(global_permission)
      end
    end
  end

  describe '#global?' do
    it 'returns true for global permissions' do
      permission = create(:permission, resource_type: nil, resource_id: nil)
      expect(permission.global?).to be true
    end

    it 'returns false for scoped permissions' do
      permission = create(:permission, :scoped)
      expect(permission.global?).to be false
    end
  end

  describe '#scoped?' do
    it 'returns false for global permissions' do
      permission = create(:permission, resource_type: nil, resource_id: nil)
      expect(permission.scoped?).to be false
    end

    it 'returns true for scoped permissions' do
      permission = create(:permission, :scoped)
      expect(permission.scoped?).to be true
    end
  end

  describe '#display_name' do
    it 'returns humanized name' do
      permission = create(:permission, name: 'users.create')
      expect(permission.display_name).to eq('Users create')
    end
  end

  describe '#action_and_subject' do
    it 'extracts action and subject from dotted notation' do
      permission = create(:permission, name: 'users.create')
      expect(permission.action_and_subject).to eq(['create', 'users'])
    end

    it 'handles single word permissions' do
      permission = create(:permission, name: 'dashboard')
      expect(permission.action_and_subject).to eq(['dashboard', 'general'])
    end
  end
end
