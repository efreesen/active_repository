# ActiveRepository (Discontinued)

[[![Coverage Status](https://coveralls.io/repos/efreesen/active_repository/badge.png)](https://coveralls.io/r/efreesen/active_repository)![Build Status](https://secure.travis-ci.org/efreesen/active_repository.png)](http://travis-ci.org/efreesen/active_repository)[![Dependency Status](https://gemnasium.com/efreesen/active_repository.png)](https://gemnasium.com/efreesen/active_repository) [![Code Climate](https://codeclimate.com/github/efreesen/active_repository.png)](https://codeclimate.com/github/efreesen/active_repository)

ActiveRepository was designed so you can build your Business Models without any dependence on persistence. It by default saves your data in memory using ActiveHash (https://github.com/zilkey/active_hash). Then when you decide which kind of persistence you want to use, all you have to do is connect ActiveRepository with it.

Currently it only works with ActiveRecord and/or Mongoid, but it is easy to add adaptors. If you need any adaptor, just open an issue!

With it you can always run your tests directly into memory, boosting your suite's speed. If you need to run all tests or a single spec using persistence you can do it too.

Check out our benchmark:

* **ActiveRepository:**
  Finished in **2.96** seconds
  90 examples, 0 failures

* **ActiveRecord:**
  Finished in **6.29** seconds
  90 examples, 0 failures

* **Mongoid:**
  Finished in **7.01** seconds
  90 examples, 0 failures

In ActiveRepository you will always work with ActiveRepository objects, so you can create relations between ActiveRecord and Mongoid seamlessly. You can even use Mongoid's Origin query format or keep with the SQL format no matter what kind of persistence you are using, we convert it for you!

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

To use it your class should inherit ActiveRepository::Base:

    class UserRepository < ActiveRepository::Base
      persistence_class = User
      save_in_memory = false
    end

ActiveRepository::Base has two class attributes to help it identify where it is going to persist data.

###persistence_class

This attribute is used to identify the class responsible for persisting data, it should be the ActiveRecord model or the Mongoid Document. Let's say your ActiveRecord Model is called User, using the example above, all database actions would be passed to User class, and you can extract all your business logic to the UserRepository class.

###save_in_memory

This attribute is used to persist data directly into memory. When set to true, it ignores the persistence_class attribute and save in memory. If set to false it goes back to persistence_class. You can use it to keep your tests saving in memory, or set it to false manually if a test need to touch the database.

If using Rails you can even tie it to your environment, so in tests it is set to true and otherwise it is set to false, like this:

    class UserRepository < ActiveRepository::Base
      persistence_class = User
      save_in_memory = Rails.env.test?
    end

###postfix

ActiveRepository also has an attribute to help you keep your code clean, the postfix. It can be used to define a pattern for Persistence classes so you don't need to keep declaring it everywhere. When using it, your persistence_class name would be \<repository_class_name\> + \<postfix\>.

Here is an example, let's say you have a bunch of Mongoid Documents and you don't want to declare persistence_class for each repository. So you can create a Base Repository and declare the postfix:

    class BaseRepository < ActiveRepository::Base
      # Defines the postfix
      postfix "Document"

      save_in_memory = false
    end

You have to rename your Mongoid Documents to the defined pattern, like this:

    class UserDocument
      include Mongoid::Document
    end

And you can create your repositories inheriting from BaseRepository:

    class User < BaseRepository
    end

Then you are good to go!!!

###Setting fields

After defining the persistence options, you can set the fields it is going to use:

    class UserRepository < ActiveRepository::Base
      # Defines the fields of the class
      fields :name, :email, :birthdate

      persistence_class = User
      save_in_memory = false
    end

Now you are all set and ready to go. Your business logic is decoupled from the persistence tier!

You can check an example project here: https://github.com/efreesen/sports_betting_engine

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
