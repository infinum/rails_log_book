# require 'spec_helper'

# RSpec.describe LogBook::SaveRecords do
#   before do
#     LogBook.enable_recording
#     LogBook::Store.tree = LogBook::Tree.new
#   end

#   context 'without squashing' do
#     before { LogBook.config.record_squashing = false }

#     it 'saves all records' do
#       LogBook::Store.tree.nodes = {
#         "record_1": build(:record, record_changes: { email: [nil, 'email'] }),
#         "record_2": build(:record, record_changes: { email: ['email', 'name'] })
#       }

#       expect do
#         described_class.call
#       end.to change(LogBook::Record, :count).by(2)
#     end
#   end

#   context 'with squashing' do
#     before { LogBook.config.record_squashing = true }

#     it 'saves all records' do
#       LogBook::Store.records = {
#         record_1: build(:record, record_changes: { email: [nil, 'email'] }),
#         record_2: build(:record, record_changes: { email: ['email', 'name'] })
#       }

#       expect do
#         described_class.call
#       end.to change(LogBook::Record, :count).by(2)
#     end

#     it '1 parent' do
#       LogBook::Store.records = {
#         record_1: build(:record, record_changes: { email: [nil, 'email'] }),
#         record_2: build(:record, record_changes: { email: ['email', 'name'] }, parent_key: :record_1)
#       }

#       expect do
#         described_class.call
#       end.to change(LogBook::Record, :count).by(1)
#     end

#     it '2 parents' do
#       LogBook::Store.records = {
#         record_2: build(:record, record_changes: { email: ['email', 'name'] }, parent_key: :record_1),
#         record_3: build(:record, record_changes: { email: ['glo', 'name'] }, parent_key: :record_1),
#         record_1: build(:record, record_changes: { email: [nil, 'email'] })
#       }

#       expect do
#         described_class.call
#       end.to change(LogBook::Record, :count).by(1)
#     end

#     it '2 transient parents' do
#       LogBook::Store.records = {
#         record_2: build(:record, record_changes: { email: ['email', 'name'] }, parent_key: :record_1, recording_key: :record_2),
#         record_3: build(:record, record_changes: { email: ['glo', 'name'] }, parent_key: :record_2, recording_key: :record_3),
#         record_1: build(:record, record_changes: { email: [nil, 'email'] }, recording_key: :record_1)
#       }

#       expect do
#         described_class.call
#         require 'pry'; binding.pry
#       end.to change(LogBook::Record, :count).by(1)
#     end
#   end
# end
