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
      changes = record.record_changes
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

  let(:valid_params_withouth_company) do
    { company: {
      users_attributes: [
        { name: 'User1', email: 'user1@email.com' },
        { name: 'User2', email: 'user2@email.com' },
        { name: 'User3', email: 'user3@email.com' }
      ]
    } }
  end

  let(:valid_params_with_non_squashable) do
    { company: {
      users_attributes: [
        { name: 'User1', email: 'user1@email.com' },
        { name: 'User2', email: 'user2@email.com' }
      ],
      company_info_attributes: { address: 'Negdje' }
    } }
  end

  describe '#create' do
    it 'creates a company and all its users' do
      expect do
        post :create, params: valid_params, session: { user_id: @user.id }
      end.to change(LogBook::Record, :count).by(4)

      logs = LogBook::Record.all
      expect(logs.map(&:request_uuid).uniq.count).to eq(1)
      expect(logs.map(&:action).uniq.count).to eq(1)
    end
  end

  describe 'squashing' do
    it 'squashes records' do
      LogBook.config.record_squashing = true
      expect do
        post :create, params: valid_params, session: { user_id: @user.id }
      end.to change(LogBook::Record, :count).by(1)

      log = LogBook::Record.last
      expect(log.record_changes).to have_key('users')
      expect(log.record_changes['users'].count).to eq(3)
      expect(log.meta).to have_key('users')
      expect(log.meta['users'].count).to eq(3)
    end

    it 'squashes records without parent record' do
      LogBook.config.record_squashing = true
      expect do
        post :create, params: valid_params_withouth_company, session: { user_id: @user.id }
      end.to change(LogBook::Record, :count).by(1)

      log = LogBook::Record.last
      expect(log.subject_type).to eq('Company')
      expect(log.record_changes).to have_key('users')
      expect(log.record_changes['users'].count).to eq(3)
      expect(log.meta).to have_key('users')
      expect(log.meta['users'].count).to eq(3)
    end

    it 'squashes records without parent' do
      LogBook.config.record_squashing = true
      company = Company.create(name: 'something')
      expect do
        patch :update, params: {id: company.id, company: {name: 'something else'}}, session: { user_id: @user.id }
      end.to change(LogBook::Record, :count).by(1)

      log = LogBook::Record.last
      expect(log.subject_type).to eq('Company')
      expect(log.record_changes).to have_key('name')
      expect(log.record_changes).to have_key('description')
    end

    it 'squashes only squashable records' do
      LogBook.config.record_squashing = true
      expect do
        post :create, params: valid_params_with_non_squashable, session: { user_id: @user.id }
      end.to change(LogBook::Record, :count).by(2)

      log = LogBook::Record.last
      expect(log.subject_type).to eq('CompanyInfo')
      expect(log.record_changes).to have_key('address')
    end
  end
end
