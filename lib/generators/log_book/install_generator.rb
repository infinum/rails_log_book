require 'rails/generators/migration'
require 'generators/log_book/migration'
require 'rails_log_book'

module LogBook
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      extend LogBook::Generators::Migration

      source_root File.expand_path('../templates', __FILE__)

      def copy_initalizer
        copy_file 'initializer.rb', 'config/initializers/log_book.rb'
      end

      def copy_migration
        migration_template 'install.rb', 'db/migrate/install_log_book.rb'
      end

      def migration_version
        if rails5?
          "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
        end
      end
    end
  end
end
