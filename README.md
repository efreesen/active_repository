# ActiveRepository

ActiveRepository was designed so you can build your Business Models without depending on any ORM. It by default saves your data in memory using ActiveHash (https://github.com/zilkey/active_hash). Then when you decides which ORM you want to use you only have to connect ActiveRepository with it.

Presently it only works with ActiveRecord. We are working on mongoid support.

It also has the advantage of letting you test directly in memory, with no need to save data on disk, which gives a great boost to your test suite speed.

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
