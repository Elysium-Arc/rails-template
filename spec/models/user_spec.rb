require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:sessions).dependent(:destroy) }
    it { should have_many(:user_roles).dependent(:destroy) }
    it { should have_many(:roles).through(:user_roles) }
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

  describe 'role and permission methods' do
    let(:user) { create(:user) }
    let(:admin_role) { create(:role, name: 'admin') }
    let(:user_role) { create(:role, name: 'user') }
    let(:permission) { create(:permission, name: 'users.index') }

    describe '#has_role?' do
      it 'returns true when user has the role' do
        user.roles << admin_role
        expect(user.has_role?('admin')).to be true
      end

      it 'returns false when user does not have the role' do
        expect(user.has_role?('admin')).to be false
      end
    end

    describe '#has_any_role?' do
      it 'returns true when user has any of the roles' do
        user.roles << user_role
        expect(user.has_any_role?('admin', 'user')).to be true
      end

      it 'returns false when user has none of the roles' do
        expect(user.has_any_role?('admin', 'moderator')).to be false
      end
    end

    describe '#has_permission?' do
      before do
        admin_role.permissions << permission
        user.roles << admin_role
      end

      it 'returns true when user has the permission through role' do
        expect(user.has_permission?('users.index')).to be true
      end

      it 'returns false when user does not have the permission' do
        expect(user.has_permission?('users.destroy')).to be false
      end
    end

    describe '#add_role' do
      it 'adds role to user' do
        expect {
          user.add_role(admin_role)
        }.to change { user.roles.count }.by(1)
      end

      it 'does not add duplicate role' do
        user.roles << admin_role
        expect {
          user.add_role(admin_role)
        }.not_to change { user.roles.count }
      end
    end

    describe '#remove_role' do
      before { user.roles << admin_role }

      it 'removes role from user' do
        expect {
          user.remove_role(admin_role)
        }.to change { user.roles.count }.by(-1)
      end
    end

    describe '#permission_names' do
      before do
        permission2 = create(:permission, name: 'users.create')
        admin_role.permissions << [permission, permission2]
        user.roles << admin_role
      end

      it 'returns array of permission names' do
        expect(user.permission_names).to match_array(['users.index', 'users.create'])
      end

      it 'returns unique permission names' do
        user_role.permissions << permission
        user.roles << user_role
        expect(user.permission_names.count('users.index')).to eq(1)
      end
    end
  end
end
