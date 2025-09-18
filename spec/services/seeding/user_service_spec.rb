# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Seeding::UserService do
  describe '.create_user' do
    let(:email) { 'test@example.com' }
    let(:password) { 'password123' }

    context 'when user does not exist' do
      it 'creates a new user' do
        expect {
          described_class.create_user(email, password)
        }.to change(User, :count).by(1)
      end

      it 'creates user with correct email' do
        user = described_class.create_user(email, password)
        expect(user.email_address).to eq(email)
      end

      it 'creates user with encrypted password' do
        user = described_class.create_user(email, password)
        expect(user.authenticate(password)).to eq(user)
      end
    end

    context 'when user already exists' do
      before do
        create(:user, email_address: email)
      end

      it 'does not create a duplicate user' do
        expect {
          described_class.create_user(email, password)
        }.to_not change(User, :count)
      end

      it 'returns the existing user' do
        existing_user = User.find_by(email_address: email)
        result = described_class.create_user(email, password)
        expect(result).to eq(existing_user)
      end
    end

    context 'with invalid parameters' do
      it 'raises an error with empty email' do
        expect {
          described_class.create_user('', password)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'raises an error with short password' do
        expect {
          described_class.create_user(email, 'short')
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
