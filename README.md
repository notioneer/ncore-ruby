# NCore

NCore is a Ruby gem designed to help build REST API clients. It is not an API
client by itself, but provides several useful building blocks to build one.

It relies on `excon` for HTTP handling and `activesupport`.

If present, uses `multi_json`. Otherwise, the stdlib 'json' is used.
'multi_json' with an accelerated json gem is recommended.

See `example/` for the beginning of an actual api client.


## Installation

Add this line to your application's Gemfile:

    gem 'ncore'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ncore


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
