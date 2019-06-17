# LogBook

LogBook is a gem that tracks changes on your records. Created for the purpuse of auditing and showing activity log.
For comparison with [paper_\__trail](https://github.com/airblade/paper_trail) and [audited](https://github.com/collectiveidea/audited) see []()

## Supported ORMs

Currently only supports ActiveRecord.

## Instalation

Add to your Gemfile:

``` ruby
gem 'rails_log_book'
```

Then run:

```ruby
rails generate log_book:install
rake db:migrate
```
## Reasoning

We built this gem because others did not offer us what we needed.

Benefits:
- new features ([Squashing](#squashing))
- Explicit (needs to be told when to record, as opposed to paper_trail or audited which always record; ie. do not record stuff done in console)
- Has an inbuilt caching mechanism with `meta` field
- ``meta`` field can also be used to add aditional keys on which search queries can be run

## Usage

Add to models you want to keep track of:

``` ruby
  class User < ActiveRecord::Base
    include LogBook::Recorder

    has_log_book_records
  end
```

Add to controlers and actions you want the tracker to be active:

``` ruby
  class UsersController < ApplicationController
    include LogBook::ControllerRecord
  end
```

By default, whenever a user record is created, updated or deleted in any actions of users\_controller a new log\_book record will be created.

## Squashing

The idea of squashing came when we needed to show an activity page where you have a has_many relation setup but you need to show changes only on the "main" object.

Example:

```ruby
class Hotel < ApplicationRecord
  include LogBook::Recorder
  has_log_book_records

  has_many :amenities
  accepts_nested_attributes_for :amenities
end

class HotelAmenity < ApplicationRecord
  include LogBook::Recorder
  has_log_book_records, parent: :hotel

  belongs_to :hotel
  belongs_to :amenity
end

class Amenity < ApplicationRecord
  has_many :hotels
end

class HotelsController < ApplicationController
  def create
    @hotel = Hotel.create(hotel_params)
  end

  def hotel_params
    params.require(:hotel).permit(amenities_attributes: [:id, :status])
  end
end

# having this params passed to hotels_controller:
{ name: 'Hotel', amenitites_attributes: { 0: {id: 1, status: :avaliable}, 1: { id: 4, status: :unavaliable } } }

# Without squashing you would have these records in the DB (abbreviated for clairity)
[
  {subject_type: 'Hotel',        subject_id: 1, parent_type: nil,     parent_id: nil, record_changes: { name: [nil, 'Hotel']}},
  {subject_type: 'HotelAmenity', subject_id: 1, parent_type: 'Hotel', parent_id: 1,   record_changes: { name: [nil, 'avaliable']}},
  {subject_type: 'HotelAmenity', subject_id: 4, parent_type: 'Hotel', parent_id: 1,   record_changes: { name: [nil, 'unavaliable']}},
]

# The above is rather difficult to paginate if you want to show changes done on HotelAmenities to show under Hotel.
# With squashing enabled:
[
  {
    subject_type: 'Hotel',
    subject_id: 1,
    parent_type: nil,
    parent_id: nil,
    record_changes: {
      name: [nil, 'Hotel'],
      hotel_amenitites: {
        1: {status: [nil, 'avaliable']},
        2: {status: [nil, 'unavaliable']}
      }
    }
  }
]

```

## ActiveRecord Options

### fields

``` ruby
  class User < ActiveRecord::Base
    include LogBook::Recorder

    # all fields
    # has_log_book_records

    # Only fields
    # has_log_book_records only: [:email, :name]

    # Ignored fields
    # has_log_book_records except: [:password]

    # Default ignored fields
    # primary_key (id), LogBook.config.ignored_attributes (:created_at, :updated_at)
  end
```

### callbacks

``` ruby
  class User < ActiveRecord::Base
    include LogBook::Recorder

    # all events
    # has_log_book_records

    # Only record on create and destroy (not update)
    # has_log_book_records on: [:create, :destroy]
  end
```

### parent

Define who is a parent of this object.

``` ruby
  class User < ActiveRecord::Base
    include LogBook::Recorder
    belongs_to :company

    # Parent is Company and will be recorded with each user change
    # has_log_book_records parent: :company
  end
```

### parent_of

Define who this object is a parent of.

``` ruby
  class Account < ActiveRecord::Base
    include LogBook::Recorder
    has_many :user_memberships
    has_many :users, through: :user_memberships
  end

  def UserMembership < ActiveRecord::Base
    belongs_to :account
    belongs_to :user
  end

  class User < ActiveRecord::Base
    has_one :user_membership
    has_one :account, through: :user_membership

    # Parent is Company and will be recorded with each user change
    # has_log_book_records parent_of: :account
  end
```

### meta

Arbitrary column. This is a jsonb field which can have all kinds of information. Useful when you want to cache fields at the exact point of record creation

``` ruby
  class User < ActiveRecord::Base
    include LogBook::Recorder

    # runs `log_book_meta(record)` method to assign to `:meta` field
    # has_log_book_records meta: true

    # runs `meta_method` method to assing to `:meta` field
    # has_log_book_records meta: :meta_method

    # runs passed proc to assing to `:meta` field
    # has_log_book_records meta: -> { { slug: email.split('@').first } }
  end
```

## ActionController options

### current\_author

Defines what method is run when looking for the author for recording

``` ruby
  class Admin::UsersController < ActionController::Base
    inlcude LogBook::ControllerRecord

    # defaults to `current_user`
    def current_author
      current_admin
    end
```

## Configuration

``` ruby
# config/initializers/log_book.rb
LogBook.configure do |config|
  config.records_table_name = 'records'
  config.ignored_attributes = [:updated_at, :created_at]
  config.author_method = :current_user
  config.record_squashing = false
  config.recording_enabled = false
  config.skip_if_empty_actions = [:update]
end
```

## Additional methods

``` ruby
LogBook.with_recording {}         #=> Enables recording within block
LogBook.author=(author     )      #=> Records as a different author within block
LogBook.action=(value)            #=> Change default action for this request
LogBook.with_record_squashing {}  #=> Squashes records within block
LogBook.enable_recording          #=> Enables recording from this point
LogBook.disable_recording         #=> Disables recording from this point
LogBook.record_squashing_enabled  #=> Enables record squashing from this point
LogBook.recording_enabled         #=> Returns true if recording is enabled
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/infinum/log_book. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

