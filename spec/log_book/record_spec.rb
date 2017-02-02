require 'spec_helper'

describe LogBook::Record do
  let(:user)    { User.create(email: 'admin') }
  let!(:record) { LogBook::Record.create(author: user) }

  it 'record created' do
    expect(LogBook::Record.count).to eq(1)
  end
end
