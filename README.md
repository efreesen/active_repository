# ActiveRepository

[![Build Status](https://secure.travis-ci.org/efreesen/active_repository.png)](http://travis-ci.org/efreesen/active_repository)[![Dependency Status](https://gemnasium.com/efreesen/active_repository.png)](https://gemnasium.com/efreesen/active_repository) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/efreesen/active_repository)

ActiveRepository was designed so you can build your Business Models without depending on any ORM. It by default saves your data in memory using ActiveHash (https://github.com/zilkey/active_hash). Then when you decide which ORM you want to use you only have to connect ActiveRepository with it.

Currently it only works with ActiveRecord and/or Mongoid.

It also has the advantage of letting you test directly in memory, with no need to save data on disk, which gives a great boost to your test suite speed.

Here are some data for comparison:

* **ActiveRepository:**
  Finished in **0.63357** seconds;
  78 examples, 0 failures

* **ActiveRecord:**
  Finished in **3.78** seconds;
  78 examples, 0 failures

* **Mongoid:**
  Finished in **5.25** seconds;
  78 examples, 0 failures

With ActiveRepository you can make associations with ActiveRecord, Mongoid and ActiveRepository seamlessly.

## Requirements

### Ruby

ActiveRepository requires Ruby version **>= 1.9.3**.

## Installation

Add this line to your application's Gemfile:

    gem 'active_repository'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_repository

## Usage

Firstly you must inherit ActiveRepository::Base:

    class User < ActiveHash::Base
      # Defines the fields of the class
      fields :name, :email, :birthdate

      # Defines the class responsible for persisting data
      set_model_class(Country)

      # Set this to true in order to ignore model_class attribute and persist in memory
      set_save_in_memory(true)
    end

Then it is just using it as if it was your ActiveRecord model or Mongoid Document.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
