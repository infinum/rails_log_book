require 'spec_helper'

describe LogBook::Recorder do
  before { LogBook.disable_recording }

  context '.with_recording' do
    it 'creates a record' do
      expect do
        LogBook.with_recording do
          User.create(email: 'test', name: 'test', address: 'nowere')
        end
      end.to change(LogBook::Record, :count).by(1)

      record = LogBook::Record.last
      expect(record.parent).to be_nil
      expect(record.meta).to eq({})
      changes = record.record_changes
      expect(changes).to have_key('email')
      expect(changes).to have_key('name')
      expect(changes).to have_key('address')
      expect(changes).to_not have_key('id')
      expect(changes).to_not have_key('created_at')
    end

    it 'updates a record' do
      user = User.create(email: 'test', name: 'test', address: 'nowere')
      expect do
        LogBook.with_recording do
          user.update(email: 'test1')
        end
      end.to change(LogBook::Record, :count).by(1)

      record = LogBook::Record.last
      changes = record.record_changes
      expect(changes).to have_key('email')
      expect(changes).to_not have_key('name')
      expect(changes).to_not have_key('address')
    end

    it 'destroys a record' do
      user = User.create(email: 'test', name: 'test', address: 'nowere')
      expect do
        LogBook.with_recording do
          user.destroy
        end
      end.to change(LogBook::Record, :count).by(1)

      record = LogBook::Record.last
      # expect(record.record_changes).to eq({})
    end

    context ':only' do

      it 'creates a email only record' do
        expect do
          LogBook.with_recording do
            UserOnly.create(email: 'test', name: 'test', address: 'nowere')
          end
        end.to change(LogBook::Record, :count).by(1)

        record = LogBook::Record.last
        changes = record.record_changes
        expect(changes).to have_key('email')
        expect(changes).to_not have_key('name')
        expect(changes).to_not have_key('address')
      end
    end

    context ':meta' do
      context 'meta: true' do
        it 'creates a user with meta' do
          expect do
            LogBook.with_recording do
              UserMetaTrue.create(email: 'test', name: 'test', address: 'nowere')
            end
          end.to change(LogBook::Record, :count).by(1)

          record = LogBook::Record.last
          expect(record.meta['name']).to eq('test')
          expect(record.meta['arbitraty']).to eq('arbitraty')
        end
      end

      context 'meta: symbol' do
        it 'creates a user with meta' do
          expect do
            LogBook.with_recording do
              UserMetaSymbol.create(email: 'test', name: 'test', address: 'nowere')
            end
          end.to change(LogBook::Record, :count).by(1)

          record = LogBook::Record.last
          expect(record.meta['name']).to eq('test')
          expect(record.meta['arbitraty']).to eq('arbitraty')
        end
      end

      context 'meta: proc' do
        it 'creates a user with meta' do
          expect do
            LogBook.with_recording do
              UserMetaProc.create(email: 'test', name: 'test', address: 'nowere')
            end
          end.to change(LogBook::Record, :count).by(1)

          record = LogBook::Record.last
          expect(record.meta['name']).to eq('test')
          expect(record.meta['arbitraty']).to eq('arbitraty')
        end
      end
    end

    context '.record_as' do
      it 'creates a record with author' do
        user = User.create(email: 'test', name: 'test', address: 'nowere')
        expect do
          LogBook.with_recording do
            LogBook.author = user
            UserOnly.create(email: 'test', name: 'test', address: 'nowere')
          end
        end.to change(LogBook::Record, :count).by(1)

        record = LogBook::Record.last
        changes = record.record_changes
        expect(changes).to have_key('email')
        expect(changes).to_not have_key('name')
        expect(changes).to_not have_key('address')
        expect(record.author).to eq(user)
      end
    end

    context '.record_action' do
      it 'creates a record with action' do
        expect do
          LogBook.with_recording do
            LogBook.action = 'create'
            UserOnly.create(email: 'test', name: 'test', address: 'nowere')
          end
        end.to change(LogBook::Record, :count).by(1)

        record = LogBook::Record.last
        expect(record.action).to eq('create')
        changes = record.record_changes
        expect(changes).to have_key('email')
        expect(changes).to_not have_key('name')
        expect(changes).to_not have_key('address')
      end
    end
  end

  # context ':parent' do
  #   it 'creates a record with parent' do
  #     company = Company.create(name: 'company')
  #     expect do
  #       LogBook.with_recording do
  #         UserWithCompany.create(email: 'test', name: 'test', address: 'nowere', company: company)
  #       end
  #     end.to change(LogBook::Record, :count).by(1)

  #     record = LogBook::Record.last
  #     require 'pry'; binding.pry
  #     expect(record.parent).to eq(company)
  #   end
  # end

  context ':skip_if_empty_actions' do
    it 'skip an empty update' do
      user = UserOnly.create(email: 'test', name: 'test', address: 'nowere')
      expect do
        LogBook.with_recording do
          LogBook.author = user
          user.update(name: 'test1')
        end
      end.to change(LogBook::Record, :count).by(0)
    end
  end

  it 'does nothing' do
    expect do
      UserOnly.create(email: 'test', name: 'test', address: 'nowere')
    end.to change(LogBook::Record, :count).by(0)
  end
end
