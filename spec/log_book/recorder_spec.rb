require 'spec_helper'

describe LogBook::Recorder do
  context '.with_recording' do
    it 'creates a record' do
      expect do
        Models::User.with_recording do
          Models::User.create(email: 'test', name: 'test', address: 'nowere')
        end
      end.to change(LogBook::Record, :count).by(1)

      record = LogBook::Record.last
      expect(record.action).to eq('create')
      expect(record.parent).to be_nil
      expect(record.meta).to be_nil
      changes = record.record_changes['users']
      expect(changes).to have_key('email')
      expect(changes).to have_key('name')
      expect(changes).to have_key('address')
      expect(changes).to_not have_key('id')
      expect(changes).to_not have_key('created_at')
    end

    it 'updates a record' do
      user = Models::User.create(email: 'test', name: 'test', address: 'nowere')
      expect do
        user.with_recording do
          user.update(email: 'test1')
        end
      end.to change(LogBook::Record, :count).by(1)

      record = LogBook::Record.last
      expect(record.action).to eq('update')
      changes = record.record_changes['users']
      expect(changes).to have_key('email')
      expect(changes).to_not have_key('name')
      expect(changes).to_not have_key('address')
    end

    it 'destroys a record' do
      user = Models::User.create(email: 'test', name: 'test', address: 'nowere')
      expect do
        Models::User.with_recording do
          user.destroy
        end
      end.to change(LogBook::Record, :count).by(1)

      record = LogBook::Record.last
      expect(record.action).to eq('destroy')
      expect(record.record_changes['users']).to eq({})
    end

    context ':only' do

      it 'creates a email only record' do
        expect do
          Models::User.with_recording do
            Models::UserOnly.create(email: 'test', name: 'test', address: 'nowere')
          end
        end.to change(LogBook::Record, :count).by(1)

        record = LogBook::Record.last
        expect(record.action).to eq('create')
        changes = record.record_changes['users']
        expect(changes).to have_key('email')
        expect(changes).to_not have_key('name')
        expect(changes).to_not have_key('address')
      end
    end

    context ':meta' do
      context 'meta: true' do
        it 'creates a user with meta' do
          expect do
            Models::User.with_recording do
              Models::UserMetaTrue.create(email: 'test', name: 'test', address: 'nowere')
            end
          end.to change(LogBook::Record, :count).by(1)

          record = LogBook::Record.last
          expect(record.action).to eq('create')
          expect(record.meta['users']['name']).to eq('test')
          expect(record.meta['users']['arbitraty']).to eq('arbitraty')
        end
      end

      context 'meta: symbol' do
        it 'creates a user with meta' do
          expect do
            Models::User.with_recording do
              Models::UserMetaSymbol.create(email: 'test', name: 'test', address: 'nowere')
            end
          end.to change(LogBook::Record, :count).by(1)

          record = LogBook::Record.last
          expect(record.action).to eq('create')
          expect(record.meta['users']['name']).to eq('test')
          expect(record.meta['users']['arbitraty']).to eq('arbitraty')
        end
      end

      context 'meta: proc' do
        it 'creates a user with meta' do
          expect do
            Models::User.with_recording do
              Models::UserMetaProc.create(email: 'test', name: 'test', address: 'nowere')
            end
          end.to change(LogBook::Record, :count).by(1)

          record = LogBook::Record.last
          expect(record.action).to eq('create')
          expect(record.meta['users']['name']).to eq('test')
          expect(record.meta['users']['arbitraty']).to eq('arbitraty')
        end
      end
    end

    context '.record_as' do
      it 'creates a record with author' do
        user = Models::User.create(email: 'test', name: 'test', address: 'nowere')
        expect do
          Models::User.with_recording do
            Models::User.record_as(user) do
              Models::UserOnly.create(email: 'test', name: 'test', address: 'nowere')
            end
          end
        end.to change(LogBook::Record, :count).by(1)

        record = LogBook::Record.last
        expect(record.action).to eq('create')
        changes = record.record_changes['users']
        expect(changes).to have_key('email')
        expect(changes).to_not have_key('name')
        expect(changes).to_not have_key('address')
        expect(record.author).to eq(user)
      end
    end
  end

  context ':parent' do
    it 'creates a record with parent' do
      company = Models::Company.create(name: 'company')
      expect do
        Models::User.with_recording do
          Models::UserWithCompany.create(email: 'test', name: 'test', address: 'nowere', company: company)
        end
      end.to change(LogBook::Record, :count).by(1)

      record = LogBook::Record.last
      expect(record.action).to eq('create')
      expect(record.parent).to eq(company)
    end
  end

  it 'does nothing' do
    expect do
      Models::UserOnly.create(email: 'test', name: 'test', address: 'nowere')
    end.to change(LogBook::Record, :count).by(0)
  end
end
