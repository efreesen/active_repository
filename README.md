# ActiveRepository

ActiveRepository is designed so you can build your Business Models without depending on any ORM, it by default saves your data in memory using ActiveHash (https://github.com/zilkey/active_hash) gem. Then when you decides which ORM you want to use you only have to connect ActiveRepository with it. Actually it only works with ActiveRecord, we are working to give mongoid suppoort.

It also has the advantage of letting you test directly in memory, no need to save data in disk. This gives a great boost on your test suite speed.

## Requirements

### Ruby

ActiveRepository requires Ruby version **>= 1.9.2**.

## Installation

Add this line to your application's Gemfile:

    gem 'active_repository'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_repository

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
