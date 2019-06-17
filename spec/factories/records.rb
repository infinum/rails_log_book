FactoryBot.define do
  factory :record, class: LogBook::Recorder::RecordingChanges do
    initialize_with { new(create(:user)) }
  end
end
