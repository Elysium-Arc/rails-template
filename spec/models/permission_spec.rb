# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Permission, type: :model do
  describe 'associations' do
    it { should have_many(:role_permissions).dependent(:destroy) }
    it { should have_many(:roles).through(:role_permissions) }
  end

  describe 'validations' do
    subject { build(:permission) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_length_of(:description).is_at_most(500) }

    context 'uniqueness' do
      it 'validates uniqueness of name scoped to resource_type and resource_id' do
        create(:permission, name: 'users.index', resource_type: nil, resource_id: nil)
        duplicate = build(:permission, name: 'users.index', resource_type: nil, resource_id: nil)
        expect(duplicate).to_not be_valid
        expect(duplicate.errors[:name]).to be_present
      end

      it 'allows same name for different resource types' do
        create(:permission, name: 'manage', resource_type: 'Project', resource_id: 1)
        duplicate = build(:permission, name: 'manage', resource_type: 'Team', resource_id: 1)
        expect(duplicate).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:global_permission) { create(:permission, resource_type: nil, resource_id: nil) }
    let!(:project_permission) { create(:permission, resource_type: 'Project', resource_id: 1) }
    let!(:team_permission) { create(:permission, resource_type: 'Team', resource_id: 2) }

    describe '.global' do
      it 'returns only global permissions' do
        expect(Permission.global).to include(global_permission)
        expect(Permission.global).not_to include(project_permission, team_permission)
      end
    end

    describe '.resource_specific' do
      it 'returns permissions for specific resource type' do
        expect(Permission.resource_specific('Project')).to include(project_permission)
        expect(Permission.resource_specific('Project')).not_to include(global_permission, team_permission)
      end

      it 'returns permissions for specific resource type and id' do
        expect(Permission.resource_specific('Project', 1)).to include(project_permission)
        expect(Permission.resource_specific('Project', 2)).to be_empty
      end
    end
  end

  describe '#global?' do
    it 'returns true for global permissions' do
      permission = create(:permission, resource_type: nil, resource_id: nil)
      expect(permission.global?).to be true
    end

    it 'returns false for resource-specific permissions' do
      permission = create(:permission, resource_type: 'Project', resource_id: 1)
      expect(permission.global?).to be false
    end
  end

  describe '.ransackable_attributes' do
    it 'returns allowed attributes for search' do
      expect(Permission.ransackable_attributes).to match_array(
        %w[id name description resource_type resource_id created_at updated_at]
      )
    end
  end

  describe '.ransackable_associations' do
    it 'returns allowed associations for search' do
      expect(Permission.ransackable_associations).to match_array(%w[roles])
    end
  end

  describe '#to_key' do
    let(:permission) { create(:permission) }

    it 'returns array with hashid' do
      expect(permission.to_key).to eq([permission.hashid])
    end
  end

  describe 'auditing' do
    it 'creates audit records on create' do
      expect {
        create(:permission)
      }.to change { Audited::Audit.count }.by(1)
    end

    it 'creates audit records on update' do
      permission = create(:permission)
      expect {
        permission.update(name: 'updated_permission')
      }.to change { Audited::Audit.count }.by(1)
    end
  end

  describe 'hashid' do
    it 'generates a hashid' do
      permission = create(:permission)
      expect(permission.hashid).to be_present
      expect(permission.hashid).to be_a(String)
    end

    it 'can find permission by hashid' do
      permission = create(:permission)
      found_permission = Permission.find(permission.hashid)
      expect(found_permission).to eq(permission)
    end
  end
end
