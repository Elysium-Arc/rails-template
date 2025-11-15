require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:sessions).dependent(:destroy) }
    it { should have_many(:user_roles).dependent(:destroy) }
    it { should have_many(:roles).through(:user_roles) }
    it { should have_many(:role_permissions).through(:roles) }
    it { should have_many(:permissions).through(:role_permissions) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email_address) }
    it { should validate_uniqueness_of(:email_address).case_insensitive }
    it { should validate_length_of(:email_address).is_at_most(255) }
    it { should allow_value('test@example.com').for(:email_address) }
    it { should_not allow_value('invalid_email').for(:email_address) }
    it { should_not allow_value('').for(:email_address) }

    context 'password validations' do
      it { should validate_length_of(:password).is_at_least(8).is_at_most(255).on(:create) }

      it 'validates password length on update when password is changed' do
        user = create(:user)
        user.password = 'short'
        user.password_confirmation = 'short'
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include(/is too short/)
      end
    end
  end

  describe 'normalization' do
    it 'normalizes email address to lowercase and strips whitespace' do
      user = create(:user, email_address: '  TEST@EXAMPLE.COM  ')
      expect(user.email_address).to eq('test@example.com')
    end
  end

  describe '.authenticate_by' do
    let!(:user) { create(:user, email_address: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns the user' do
        result = User.authenticate_by(email_address: 'test@example.com', password: 'password123')
        expect(result).to eq(user)
      end

      it 'handles case-insensitive email' do
        result = User.authenticate_by(email_address: 'TEST@EXAMPLE.COM', password: 'password123')
        expect(result).to eq(user)
      end

      it 'strips whitespace from email' do
        result = User.authenticate_by(email_address: '  test@example.com  ', password: 'password123')
        expect(result).to eq(user)
      end
    end

    context 'with invalid credentials' do
      it 'returns :user_not_found for non-existent email' do
        result = User.authenticate_by(email_address: 'nonexistent@example.com', password: 'password123')
        expect(result).to eq(:user_not_found)
      end

      it 'returns :invalid_password for wrong password' do
        result = User.authenticate_by(email_address: 'test@example.com', password: 'wrongpassword')
        expect(result).to eq(:invalid_password)
      end
    end
  end

  describe '#status' do
    context 'when user has no sessions' do
      let(:user) { create(:user) }

      it 'returns inactive' do
        expect(user.status).to eq('inactive')
      end
    end

    context 'when user has active session' do
      let(:user) { create(:user, :active) }

      it 'returns active' do
        Timecop.freeze(Time.current) do
          expect(user.status).to eq('active')
        end
      end
    end

    context 'when user has idle session' do
      let(:user) { create(:user, :idle) }

      it 'returns idle' do
        Timecop.freeze(Time.current) do
          expect(user.status).to eq('idle')
        end
      end
    end

    context 'when user has old session' do
      let(:user) { create(:user) }

      before do
        create(:session, user: user, updated_at: 2.days.ago)
      end

      it 'returns inactive' do
        Timecop.freeze(Time.current) do
          expect(user.status).to eq('inactive')
        end
      end
    end
  end

  describe '.ransackable_attributes' do
    it 'returns allowed attributes for search' do
      expect(User.ransackable_attributes).to match_array(%w[id email_address created_at updated_at])
    end
  end

  describe '.ransackable_associations' do
    it 'returns empty array' do
      expect(User.ransackable_associations).to eq([])
    end
  end

  describe '#to_key' do
    let(:user) { create(:user) }

    it 'returns array with hashid' do
      expect(user.to_key).to eq([ user.hashid ])
    end
  end

  describe 'secure password' do
    it 'encrypts password' do
      user = create(:user, password: 'password123')
      expect(user.password_digest).to_not eq('password123')
      expect(user.password_digest).to be_present
    end

    it 'authenticates with correct password' do
      user = create(:user, password: 'password123')
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'does not authenticate with wrong password' do
      user = create(:user, password: 'password123')
      expect(user.authenticate('wrongpassword')).to be false
    end
  end

  describe 'auditing' do
    it 'creates audit records on create' do
      expect {
        create(:user)
      }.to change { Audited::Audit.count }.by(1)
    end

    it 'creates audit records on update' do
      user = create(:user)
      expect {
        user.update(email_address: 'newemail@example.com')
      }.to change { Audited::Audit.count }.by(1)
    end
  end

  describe 'hashid' do
    it 'generates a hashid' do
      user = create(:user)
      expect(user.hashid).to be_present
      expect(user.hashid).to be_a(String)
    end

    it 'can find user by hashid' do
      user = create(:user)
      found_user = User.find(user.hashid)
      expect(found_user).to eq(user)
    end
  end

  describe 'RBAC methods' do
    let(:user) { create(:user) }
    let(:role) { create(:role, name: 'admin') }
    let(:permission) { create(:permission, name: 'users.create') }

    before do
      create(:role_permission, role: role, permission: permission)
    end

    describe '#add_role' do
      it 'adds a role to the user' do
        expect { user.add_role('admin') }.to change { user.roles.count }.by(1)
      end

      it 'returns true when successful' do
        expect(user.add_role('admin')).to be true
      end

      it 'returns false when role does not exist' do
        expect(user.add_role('nonexistent')).to be false
      end

      it 'is idempotent' do
        user.add_role('admin')
        expect { user.add_role('admin') }.not_to change { user.roles.count }
      end
    end

    describe '#remove_role' do
      before { user.add_role('admin') }

      it 'removes a role from the user' do
        expect { user.remove_role('admin') }.to change { user.roles.count }.by(-1)
      end

      it 'returns true when successful' do
        expect(user.remove_role('admin')).to be true
      end

      it 'returns false when role does not exist' do
        expect(user.remove_role('nonexistent')).to be false
      end
    end

    describe '#has_role?' do
      before { user.add_role('admin') }

      it 'returns true when user has the role' do
        expect(user.has_role?('admin')).to be true
      end

      it 'returns false when user does not have the role' do
        expect(user.has_role?('super_admin')).to be false
      end
    end

    describe '#has_any_role?' do
      before { user.add_role('admin') }

      it 'returns true when user has any of the roles' do
        expect(user.has_any_role?('admin', 'super_admin')).to be true
      end

      it 'returns false when user has none of the roles' do
        expect(user.has_any_role?('super_admin', 'manager')).to be false
      end
    end

    describe '#has_all_roles?' do
      let(:role2) { create(:role, name: 'manager') }

      before do
        user.add_role('admin')
        user.add_role('manager')
      end

      it 'returns true when user has all roles' do
        expect(user.has_all_roles?('admin', 'manager')).to be true
      end

      it 'returns false when user does not have all roles' do
        expect(user.has_all_roles?('admin', 'super_admin')).to be false
      end
    end

    describe '#has_permission?' do
      before { user.add_role('admin') }

      it 'returns true when user has the permission through a role' do
        expect(user.has_permission?('users.create')).to be true
      end

      it 'returns false when user does not have the permission' do
        expect(user.has_permission?('users.destroy')).to be false
      end
    end

    describe '#has_any_permission?' do
      before { user.add_role('admin') }

      it 'returns true when user has any of the permissions' do
        expect(user.has_any_permission?('users.create', 'users.destroy')).to be true
      end

      it 'returns false when user has none of the permissions' do
        expect(user.has_any_permission?('users.destroy', 'roles.destroy')).to be false
      end
    end

    describe '#has_all_permissions?' do
      let(:permission2) { create(:permission, name: 'users.update') }

      before do
        create(:role_permission, role: role, permission: permission2)
        user.add_role('admin')
      end

      it 'returns true when user has all permissions' do
        expect(user.has_all_permissions?('users.create', 'users.update')).to be true
      end

      it 'returns false when user does not have all permissions' do
        expect(user.has_all_permissions?('users.create', 'users.destroy')).to be false
      end
    end

    describe '#permission_names' do
      before { user.add_role('admin') }

      it 'returns array of permission names' do
        expect(user.permission_names).to include('users.create')
      end
    end

    describe '#role_names' do
      before { user.add_role('admin') }

      it 'returns array of role names' do
        expect(user.role_names).to include('admin')
      end
    end

    describe '#admin?' do
      it 'returns true when user has admin role' do
        user.add_role('admin')
        expect(user.admin?).to be true
      end

      it 'returns true when user has super_admin role' do
        create(:role, name: 'super_admin')
        user.add_role('super_admin')
        expect(user.admin?).to be true
      end

      it 'returns false when user has neither role' do
        expect(user.admin?).to be false
      end
    end

    describe '#super_admin?' do
      it 'returns true when user has super_admin role' do
        create(:role, name: 'super_admin')
        user.add_role('super_admin')
        expect(user.super_admin?).to be true
      end

      it 'returns false when user does not have super_admin role' do
        user.add_role('admin')
        expect(user.super_admin?).to be false
      end
    end
  end
end
