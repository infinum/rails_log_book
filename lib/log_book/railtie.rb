module LogBook
  class Railtie < Rails::Railtie
    rake_tasks do
      spec = Gem::Specification.find_by_name 'rails_log_book'
      load "#{spec.gem_dir}/lib/tasks/log_book.rake"
    end

    config.after_initialize do
      next unless LogBook.config.always_record

      at_exit do
        LogBook::SaveRecords.call
      end
    end
  end
end
