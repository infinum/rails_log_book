namespace :log_book do
  desc 'Update meta of CLASS'
  task update_meta: :environment do
    ENV['CLASS'].constantize.with_records.each do |model|
      model.records.each do |record|
        record.meta = record.meta.reverse_merge(model.log_book_meta(record).stringify_keys)
        record.save
      end
    end
  end
end
