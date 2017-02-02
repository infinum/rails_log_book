require 'spec_helper'

describe UsersController, type: :controller do
  before do
    routes.draw do
      resources :users do
        post :register, on: :collection
      end
    end
    @user = User.create(name: 'user', email: 'admin')
  end

  describe '#create' do
    it 'Creates a record' do
      expect do
        post :create, params: { user: { email: 'Email', name: 'buja' } }, session: { user_id: @user.id }
      end.to change(LogBook::Record, :count).by(1)

      record = LogBook::Record.last
      expect(record.action).to eq('create')
      expect(record.author).to eq(@user)
      changes = record.record_changes['users']
      expect(changes).to have_key('email')
      expect(changes).to have_key('name')
      expect(changes).to_not have_key('address')
    end
  end

  describe '#register' do
    it 'Custom action a record' do
      expect do
        post :register, params: { user: { email: 'Email', name: 'buja' } }, session: { user_id: @user.id }
      end.to change(LogBook::Record, :count).by(1)

      record = LogBook::Record.last
      expect(record.action).to eq('register')
    end
  end
end

describe CompaniesController, type: :controller do
  before do
    routes.draw { resources :companies }
    @user = User.create(name: 'user', email: 'admin')
  end

  let(:valid_params) do
    { company: {
      name: 'Kopmanija',
      users_attributes: [
        { name: 'User1', email: 'user1@email.com' },
        { name: 'User2', email: 'user2@email.com' },
        { name: 'User3', email: 'user3@email.com' }
      ]
    } }
  end
  describe '#create' do
    it 'creates a company and all its users' do
      expect do
        post :create, params: valid_params, session: { user_id: @user.id }
      end.to change(LogBook::Record, :count).by(4)

      logs = LogBook::Record.all
      expect(logs.map(&:record_uuid).uniq.count).to eq(1)
      expect(logs.map(&:action).uniq.count).to eq(1)
    end
  end
end
