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

  def log_book_meta(_record)
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

  def meta_info(_record)
    {
      name: name,
      arbitraty: 'arbitraty'
    }
  end
end

class UserMetaProc < ActiveRecord::Base
  include LogBook::Recorder

  self.table_name = 'users'
  has_log_book_records meta: ->(user, _record) { { name: user.name, arbitraty: 'arbitraty' } }
end

class UserWithCompany < ActiveRecord::Base
  include LogBook::Recorder

  self.table_name = 'users'
  belongs_to :company
  has_log_book_records parent: :company
end

class UserWithAll < ActiveRecord::Base
  include LogBook::Recorder

  self.table_name = 'users'
  belongs_to :company
  has_log_book_records parent: :company, meta: true, squash: true

  def log_book_meta(_record)
    {
      name: name,
      company_name: company.name
    }
  end
end
