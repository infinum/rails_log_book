require 'spec_helper'

describe LogBook do
  it 'has a version number' do
    expect(LogBook::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
