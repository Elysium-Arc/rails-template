# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'associations' do
    it { should have_many(:user_roles).dependent(:destroy) }
    it { should have_many(:users).through(:user_roles) }
    it { should have_many(:role_permissions).dependent(:destroy) }
    it { should have_many(:permissions).through(:role_permissions) }
  end

  describe 'validations' do
    subject { build(:role) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:description).is_at_most(500) }
    
    context 'uniqueness' do
      it 'validates uniqueness of name scoped to resource_type and resource_id' do
        create(:role, name: 'admin', resource_type: nil, resource_id: nil)
        duplicate = build(:role, name: 'admin', resource_type: nil, resource_id: nil)
        expect(duplicate).to_not be_valid
        expect(duplicate.errors[:name]).to be_present
      end

      it 'allows same name for different resource types' do
        create(:role, name: 'admin', resource_type: 'Project', resource_id: 1)
        duplicate = build(:role, name: 'admin', resource_type: 'Team', resource_id: 1)
        expect(duplicate).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:global_role) { create(:role, resource_type: nil, resource_id: nil) }
    let!(:project_role) { create(:role, resource_type: 'Project', resource_id: 1) }
    let!(:team_role) { create(:role, resource_type: 'Team', resource_id: 2) }

    describe '.global' do
      it 'returns only global roles' do
        expect(Role.global).to include(global_role)
        expect(Role.global).not_to include(project_role, team_role)
      end
    end

    describe '.resource_specific' do
      it 'returns roles for specific resource type' do
        expect(Role.resource_specific('Project')).to include(project_role)
        expect(Role.resource_specific('Project')).not_to include(global_role, team_role)
      end

      it 'returns roles for specific resource type and id' do
        expect(Role.resource_specific('Project', 1)).to include(project_role)
        expect(Role.resource_specific('Project', 2)).to be_empty
      end
    end
  end

  describe '#has_permission?' do
    let(:role) { create(:role) }
    let(:permission) { create(:permission, name: 'users.index') }

    it 'returns true when role has the permission' do
      role.permissions << permission
      expect(role.has_permission?('users.index')).to be true
    end

    it 'returns false when role does not have the permission' do
      expect(role.has_permission?('users.index')).to be false
    end
  end

  describe '#add_permission' do
    let(:role) { create(:role) }
    let(:permission) { create(:permission) }

    it 'adds permission to role' do
      expect {
        role.add_permission(permission)
      }.to change { role.permissions.count }.by(1)
    end

    it 'does not add duplicate permission' do
      role.permissions << permission
      expect {
        role.add_permission(permission)
      }.not_to change { role.permissions.count }
    end
  end

  describe '#remove_permission' do
    let(:role) { create(:role) }
    let(:permission) { create(:permission) }

    before { role.permissions << permission }

    it 'removes permission from role' do
      expect {
        role.remove_permission(permission)
      }.to change { role.permissions.count }.by(-1)
    end
  end

  describe '#global?' do
    it 'returns true for global roles' do
      role = create(:role, resource_type: nil, resource_id: nil)
      expect(role.global?).to be true
    end

    it 'returns false for resource-specific roles' do
      role = create(:role, resource_type: 'Project', resource_id: 1)
      expect(role.global?).to be false
    end
  end

  describe '.ransackable_attributes' do
    it 'returns allowed attributes for search' do
      expect(Role.ransackable_attributes).to match_array(
        %w[id name description resource_type resource_id created_at updated_at]
      )
    end
  end

  describe '.ransackable_associations' do
    it 'returns allowed associations for search' do
      expect(Role.ransackable_associations).to match_array(%w[users permissions])
    end
  end

  describe '#to_key' do
    let(:role) { create(:role) }

    it 'returns array with hashid' do
      expect(role.to_key).to eq([role.hashid])
    end
  end

  describe 'auditing' do
    it 'creates audit records on create' do
      expect {
        create(:role)
      }.to change { Audited::Audit.count }.by(1)
    end

    it 'creates audit records on update' do
      role = create(:role)
      expect {
        role.update(name: 'updated_role')
      }.to change { Audited::Audit.count }.by(1)
    end
  end

  describe 'hashid' do
    it 'generates a hashid' do
      role = create(:role)
      expect(role.hashid).to be_present
      expect(role.hashid).to be_a(String)
    end

    it 'can find role by hashid' do
      role = create(:role)
      found_role = Role.find(role.hashid)
      expect(found_role).to eq(role)
    end
  end
end
