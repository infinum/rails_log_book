module Models
  class User < ActiveRecord::Base
    include LogBook::Recorder

    has_log_book_records
  end

  class UserOnly < ActiveRecord::Base
    include LogBook::Recorder

    self.table_name = 'users'
    has_log_book_records only: [:email]
  end

  class UserMetaTrue < ActiveRecord::Base
    include LogBook::Recorder

    self.table_name = 'users'
    has_log_book_records meta: true

    def log_book_meta
      {
        name: name,
        arbitraty: 'arbitraty'
      }
    end
  end

  class UserMetaSymbol < ActiveRecord::Base
    include LogBook::Recorder

    self.table_name = 'users'
    has_log_book_records meta: :meta_info

    def meta_info
      {
        name: name,
        arbitraty: 'arbitraty'
      }
    end
  end

  class UserMetaProc < ActiveRecord::Base
    include LogBook::Recorder

    self.table_name = 'users'
    has_log_book_records meta: ->(user) { { name: user.name, arbitraty: 'arbitraty' } }
  end

  class UserWithCompany < ActiveRecord::Base
    include LogBook::Recorder

    self.table_name = 'users'
    belongs_to :company
    has_log_book_records parent: :company
  end
end
