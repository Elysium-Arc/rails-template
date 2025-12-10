require 'rails_helper'

RSpec.describe Permission, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:role_permissions).dependent(:destroy) }
    it { is_expected.to have_many(:roles).through(:role_permissions) }
  end

  describe 'validations' do
    subject { build(:permission) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_length_of(:description).is_at_most(1000) }

    describe 'uniqueness of name' do
      context 'global permission' do
        it 'validates uniqueness' do
          create(:permission, name: 'read')
          expect(build(:permission, name: 'read')).not_to be_valid
        end
      end

      context 'scoped permission' do
        it 'allows duplicate names for different resources' do
          create(:permission, name: 'delete', resource_type: 'Post', resource_id: 1)
          expect(build(:permission, name: 'delete', resource_type: 'Post', resource_id: 2)).to be_valid
        end

        it 'prevents duplicate names for same resource' do
          create(:permission, name: 'delete', resource_type: 'Post', resource_id: 1)
          expect(build(:permission, name: 'delete', resource_type: 'Post', resource_id: 1)).not_to be_valid
        end
      end
    end
  end

  describe '#global?' do
    it 'returns true for global permissions' do
      permission = build(:permission, resource_type: nil, resource_id: nil)
      expect(permission.global?).to be true
    end

    it 'returns false for scoped permissions' do
      permission = build(:permission, resource_type: 'Post', resource_id: 1)
      expect(permission.global?).to be false
    end
  end

  describe '#scoped?' do
    it 'returns false for global permissions' do
      permission = build(:permission, resource_type: nil, resource_id: nil)
      expect(permission.scoped?).to be false
    end

    it 'returns true for scoped permissions' do
      permission = build(:permission, resource_type: 'Post', resource_id: 1)
      expect(permission.scoped?).to be true
    end
  end

  describe 'scopes' do
    before do
      @global_perm = create(:permission, name: 'global_perm')
      @scoped_perm = create(:permission, name: 'scoped_perm', resource_type: 'Post', resource_id: 1)
    end

    describe '.global' do
      it 'returns only global permissions' do
        expect(Permission.global).to include(@global_perm)
        expect(Permission.global).not_to include(@scoped_perm)
      end
    end

    describe '.scoped_to' do
      it 'returns permissions scoped to specific resource' do
        expect(Permission.scoped_to('Post', 1)).to include(@scoped_perm)
        expect(Permission.scoped_to('Post', 1)).not_to include(@global_perm)
      end
    end

    describe '.by_name' do
      it 'finds permission by name' do
        expect(Permission.by_name('global_perm')).to include(@global_perm)
      end

      it 'is case-insensitive' do
        expect(Permission.by_name('GLOBAL_PERM')).to include(@global_perm)
      end
    end
  end
end
