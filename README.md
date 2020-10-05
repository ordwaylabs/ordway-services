# Ordway::Services

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/ordway/services`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ordway-services'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ordway-services

## Usage and guidelines to incorporate the framework in your app

## 1. How to implement?

Using this gem will help you integrate the base service structure to your application. All you have to do its take care of a few things. See below to understand what you should do after installing the gem.

### 1.1 Where your business logic should go?
Under` app -> lib -> services` folder create your service file. Say, you are implementing a payment service, create a file named payments.rb.
Your core business logic will be implemented here. This class should be inherited from `Ordway::Services::Processor` (defined in the gem).

### 1.2 Metadata configuration file
The Metadata config file should be placed under `config -> services -> post_process` folder. Make sure you name it `<service file name>.json`. Based on our example, it should be named `payments.json`. The events that should be executed after the service call, whether it is a success or failure, should be provided in this file. See the sample format [here](https://drive.google.com/file/d/1BP-JmxnvYlapR_FQl0DYlrZqirAqOJBd/view).

### 1.3 Post Processing events
As mentioned in section 1.2, when the service call is finished processing, the post-events will be executed. The list of events mentioned in the metadata file should be implemented under `app -> lib -> services -> post_events` folder. For example, if in the config file, you mentioned calling a post-event named "journal_entry", make sure you implement it under the above-mentioned path. It will look like:

 `app -> lib -> services -> post_events -> journal_entry.rb`

### 1.4 Logging
The whole request lifecycle will be logged. If you want to add additional logs in your service you can do so.
- `logger.info` - Can be used to log an INFO message
- `logger.warn` - Can be used to log a Warning
- `logger.error` -  Can be used to log an error

### 1.5 Request ID
Request ID, which is in the UUID format will help you identify the service call, and hence you can trace its lifecycle. The variable `request_id` is available within the service class as you are inheriting it from the parent class `Ordway::Services::Processor`. While logging any information or error, make sure you provide the request ID along with the log details.

### 1.6 How to make a service call?
For all services, an instance should be initialized with the appropriate attributes. Then the "call" method should be called. 
For example:

`Services::ServiceName.new(*arguments).call`

A shorthand option is to use the class method "call" directly, passing the attributes to it:

`Services::ServiceName.call(*arguments)`

If you are calling a payment service, you should call this way:

`Services::Payments.call(*arguments)`

## 2. Service Scope

Each service should focus on only one type of operation and do it well. The file size should remain fairly small. There should be only two public
methods: "initialize" and "process".

### 2.1 Stateless
Each service should be object-oriented. No service should store the state from one service instance to another. No class methods should be
present in service.

### 2.2 Base Class named "Processor"
All services must extend from `Ordway::Services::Processor`. The base class provides the following public methods to its services:

_**call**_: This method will call the method "process", which each individual service implements. In normal and validation error scenarios, the result object will be returned.

_**result**_: Initializes and returns an instance of a `Ordway::Services::Result` object, which contains a data hash, `Ordway::Services::Warning` array and `Ordway::Services::Error` array.

_**invalidate!**_: This method will optionally add a validation error object to result.errors. It will then raise a Invalid exception,
which aborts the service and is rescued in the "call" method.

_**add_validation_error**_: Adds an instance of the `Ordway::Services::Error` object to the result.errors array, with a code of
"VALIDATION_ERROR" and a message defined by the given translatable label.

_**add_warning**_: Adds an instance of `Ordway::Services::Warning `object to the result.warnings array, with a code (defaults to
"WARNING") and a message.

### 2.3 Initialization

Adding the initialize method in your service is optional since this is already done in the parent class. You can override this if needed based on your requirement. This should be used to define instance variables to be used throughout the service. To
improve maintainability, no instance variables should ever be changed after being initialized.

### 2.4 Validation
Services support multiple types of validation via the methods described in the Processor Class section. The service can be aborted immediately using the `invalidate!` method. Alternatively, error messages can be added to the array and the service can continue processing. If any errors exist, the service should make sure to rollback any changes to the database.

### 2.5 Result Object

All services will automatically return the `Ordway::Services::Result` object, which contains the following methods:

_**data**_: hash containing data applicable to this service operation that maybe need by the caller of the service

_**errors**_: an array of `Ordway::Services::Error` instances indicating a failed service

_**warnings**_: an array of `Ordway::Services::Warning` instances. Can be used if there was an issue despite a successful service call.

_**status**_: method returning true if no errors exist

The "**result**" object can be accessed anywhere throughout the service.

### 2.6 Easily Testable

All services should have test cases written for as many use cases as possible. A good approach is to ensure that test cases cover all attributes that can be passed into the service. Each service should have its own test file with a matching namespace. For example:
/test/services/payments_test.rb

### 2.7 Comments

Each service should be clearly documented in the comments. 

This includes:

**description**: A paragraph explaining the purpose of the service must be added prior to the class definition.

**input attributes**: All input attributes, including those within a hash (however deep), must be documented prior to the initialize
method. The type of attribute should be identified and if necessary, a description of what the attribute does.

**return attributes**: All possible return attributes found in result.data should be listed above the `process` method. The type of the
data attributes should be identified and if necessary, a description of the attribute.

**methods**: All methods throughout the service should have a comment above them explaining what the method does.

**other complex logic**: Any other complex logic in any method should have a comment explaining it.

### 2.8 Code Quality

All services should have zero code climate issues. Services must have a perfect quality. The code should not be duplicated anywhere else in the application. The same operation should not be found anywhere else in the application.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ordwaylabs/ordway-services. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ordway::Services project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ordwaylabs/ordway-services/blob/master/CODE_OF_CONDUCT.md).
