washout_builder
===============

[![Gem Version](https://badge.fury.io/rb/washout_builder.svg)](http://badge.fury.io/rb/washout_builder) [![Build Status](https://travis-ci.org/bogdanRada/washout_builder.png?branch=master,develop)](https://travis-ci.org/bogdanRada/washout_builder) [![Dependency Status](https://gemnasium.com/bogdanRada/washout_builder.svg)](https://gemnasium.com/bogdanRada/washout_builder) [![Documentation Status](http://inch-ci.org/github/bogdanRada/washout_builder.svg?branch=master)](http://inch-ci.org/github/bogdanRada/washout_builder) [![Coverage Status](https://coveralls.io/repos/bogdanRada/washout_builder/badge.svg?branch=master)](https://coveralls.io/r/bogdanRada/washout_builder?branch=master) [![Code Climate](https://codeclimate.com/github/bogdanRada/washout_builder/badges/gpa.svg)](https://codeclimate.com/github/bogdanRada/washout_builder) [![Repo Size](https://reposs.herokuapp.com/?path=bogdanRada/washout_builder)](https://github.com/bogdanRada/washout_builder) [![Gem Downloads](https://ruby-gem-downloads-badge.herokuapp.com/washout_builder?type=total)](https://github.com/bogdanRada/washout_builder) [![Analytics](https://ga-beacon.appspot.com/UA-72570203-1/bogdanRada/washout_builder)](https://github.com/bogdanRada/washout_builder)

Overview
--------

WashOutBuilder is a Soap Service Documentation generator (extends [WashOut](https://github.com/inossidabile/wash_out) /\)

The way [WashOut](https://github.com/inossidabile/wash_out) is used is not modified, it just extends its functionality by generating html documentation to your services that you write

NEW Improvements in version 1.5.0
---------------------------------

-	The WashoutBuilder::Engine can now be automatically be mounted in Rails application by using a simple configuration in **config/application.rb** which allows you to whitelist or blacklist the environment where WashoutBuilder::Engine can be mounted .
-	By default all the options are set to **nil**, so the engine does not get mounted automatically by default. You need to set them if you want this to work.

E.g.

```ruby
if config.respond_to?(:washout_builder) # needed in case the gem is not in the default group
  config.washout_builder.mounted_path = "/washout"  # the path where the engine should be mounted on
  config.washout_builder.whitelisted_envs = "*" # this can either be an array of strings or a string. If you specify "*" ,will mean all environments , otherwise you can specify "development" or ['development', 'staging'] or nil
  config.washout_builder.blacklisted_envs = nil # this can either be an array of strings or a string. You can specify for example "production" or ['production', 'test'], or nil
end
```

If you don't set them and they are left with default nil values, you will have to use the old way, by manually mount the engine in the Rails routes configuration file (**config/routes.rb**) by following examples below.

NEW Improvements in version 1.4.0
---------------------------------

-	when displaying all services , the link to documentation is now using the new format **/soap_doc** for better readability
-	Fixed an issue when generating documentation for a controller that didn't had the namespace set, the WSDL url and endpoint was missing from the generated source because of that. However if you don't set the namespace in controller the links to WSDL and endpoint would throw an error when trying to access them.

NEW Improvements in version 1.3.0
---------------------------------

-	link to accessing documentation for a single controller is now easier. You can use the same route as for seeing WSLD, but replacing **/wsdl** with **/soap_doc**
-	The old way of acessing documentation is still kept, so if you mounted the engine at **/washout**, you can still acess the documentation by appending to this url the full name of the controller including the namespace and the engine name(in case the controller is from a engine) as described below.

Features
--------

-	Provides way of seeing the available services with links to documentation, endpoint and namespace
-	Provides a human-readable HTML documentation generated for each service that you write

Live DEMO
=========

-	[Demo Application](http://washout-builder.herokuapp.com)

Click on the **Documentation** links on that page to see the demo application.

Hope you enjoy it :)

Demo Application Source Code
----------------------------

-	[Source Code](https://github.com/bogdanRada/washout_builder_demo)

Requirements
------------

1.	[Ruby 1.9.x or Ruby 2.x](http://www.ruby-lang.org)
2.	[Ruby On Rails](http://rubyonrails.org)
3.	[WashOut gem version >= 0.9.1](https://github.com/inossidabile/wash_out)

Compatibility
-------------

-	Rails >3.0 only. MRI 1.9, 2.0, .

-	JRuby is not offically supported since 0.15.0.

-	Ruby 1.8 is not officially supported since 0.5.3.

We will accept further compatibilty pull-requests but no upcoming versions will be tested against it.

Rubinius support temporarily dropped since 0.6.2 due to Rails 4 incompatibility.

Setup
-----

Type the following from the command line to install:

```ruby
gem install washout_builder
```

Add the following to your Gemfile:

```ruby
gem "washout_builder"
```

it will automatically install also [WashOut](https://github.com/inossidabile/wash_out) gem that is currently used

Or if you want this to be available only in development mode , you can do something like this inside the Gemfile:

```ruby
gem 'wash_out' # The WashOut gem would be used also in production

group :development, :test do
    gem 'washout_builder' # only available in development mode.
end
```

Please read [Release Details]([https://github.com/bogdanRada/washout_builder/releases) if you are upgrading. We break backward compatibility between large ticks but you can expect it to be specified at release notes.

Usage
-----

The way soap_actions, or reusable types are defined or how the configuration is made using [WashOut](https://github.com/inossidabile/wash_out) haven't changed You can still do everything that gem does .

In order to see the documentation you must write something like this in the routes (exactly like you would do when using only WashOut)

In the following file **config/routes** you can put this configuration

```ruby
WashOutSample::Application.routes.draw do
    wash_out :rumbas wash_out :my_other_service

    namespace :api do
        wash_out :project_service
    end

    mount WashoutBuilder::Engine => "/washout"
end

```

You can access the url **/washout** and you will see a list with available services ( in our case there are only two : The RumbasController and MyOtherServiceController) with links to their documentation and where you can find the WSDL.

If you want to access directly the hml documentation that was generated for RumbasController you can do that by accessing url like this:

```ruby
/washout/Rumbas                  # camelcase name
/washout/rumbas                  # without camelcase
/washout/Api::ProjectService     # for namespaced services with camelcase
/washout/api/project_service     # without camelcase
```

When specifying the **soap_service** you can also pass a **option for description** . Here is an example

```ruby
soap_service
    namespace: 'http://my.app.com/my_service/wsdl',
    description: 'here goes some description for your service'
```

When specifying the **soap_action** you can also pass a **option for description**, **option for arguments description** and a **list of exceptions(need to be classes)** that the method can raise at a certain moment.

Here is an example :

```ruby
soap_action "find",
    args: { number: :integer },
    args_description: { number: 'some description about this argument' },
    return: :boolean,
    raises: [MyCustomSoapError, MyOtherCustomSoapError ] ,
    description: "some description about this method to show in the documentation"
```

The exception classes used **must inherit** from **WashOut::Dispatcher::SOAPError**, which has by default a error code and a message as attributes .

Testing
-------

To test, do the following:

1.	cd to the gem root.
2.	bundle install
3.	bundle exec rake

Contributions
-------------

Please log all feedback/issues via [Github Issues](http://github.com/bogdanRada/washout_builder/issues). Thanks.

Contributing to washout_builder
-------------------------------

-	Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
-	Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
-	Fork the project.
-	Start a feature/bugfix branch.
-	Commit and push until you are happy with your contribution.
-	Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
-	Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Copyright (c) 2013 bogdanRada. See LICENSE.txt for further details.
