#### 3.12.0

- Allow ActiveModel 8.0

#### 3.11.0

- Allow ActiveModel 7.2, Excon 1.x

#### 3.10.0

- Allow Api.default_url and Api.credentials to be lazy loaded
- Fix detection of missing credentials
- Clarify Ruby 2.7 as minimum in gemspec; for earlier Rubies, lock to < 3.9

#### 3.9.1

- Fix clearing of memoized association when assoc_id changes

#### 3.9.0

- Add inspection filter for attributes
- Fix generation of query params when values are Hashes

#### 3.8.1

- Add option to disable some_attr?() definition

#### 3.8.0

- Add has_one association helper
- Make belongs_to return existing data even when association_key is blank
- Make reload() public for singleton resources
- Optimize calling some_attr?() by defining such methods directly.
  Previously these calls went through method_missing.

#### 3.7.1

- Don't send both mixed and lowercase headers for accept, user-agent

#### 3.7.0

- Allow request params to be or contain ActionController::Parameters
  Unless MultiJson is present, this changes json generation to use the
    configured encoder in ActiveSupport::JSON::Encoding.json_encoder instead
    of directly using ::JSON.
- Change request header names to lowercase
- Log 404, 409, 422 responses at :debug instead of :error

#### 3.6.2

- Ensure cache key is stable

#### 3.6.1

- Restore usage of Resource.new(some_attr: 'value')

#### 3.6.0

- factory() - add :preload option; make available to resource instances
- Resource.new() - add :preload option
  Hint: the first arg (attribs) must be a hash, not kwarg: `new({id: id})`
    (no longer true as of 3.6.1)

#### 3.5.2

- Fix logger=()

#### 3.5.1

- Preserve 'metadata' and 'errors' keys as attributes when inside a standard
  data payload

#### 3.5.0

- Allow ActiveModel 7.1
- Update LogSubscriber for ActiveSupport 7.1
- Associations: add arg :association_key to has_many, belongs_to
- Associations: has_many now builds retrieve_{assoc}

#### 3.4.4

- Improve keepalive handling

#### 3.4.3

- Fix Rails controller reporting of API times

#### 3.4.2

- Fix SomeResource.all when payload includes 'data' attribute

#### 3.4.1

- Allow ActiveModel 7.0

#### 3.4.0

- Add SomeResource#wait_for and WaitTimeout

#### 3.3.4

- Fix :cache option on Ruby 3.0

#### 3.3.3

- Handle recursion in #inspect

#### 3.3.2

- Ruby 3.0 compatibility

#### 3.3.1

- Fix module_parent when using ActiveSupport 5.2

#### 3.3.0

- Allow  headers: {}  as part of params/attribs everywhere
- Drop ActiveModel <= 5.1
- Remove ValidationError

#### 3.2.1

DEPRECATION NOTICE
- Support for ActiveModel < 5.2 is deprecated and will be removed in 3.3.

Other changes
- Allow ActiveModel 6.1

#### 3.2.0

- Use system's CA certificate store by default
  To use bundled CAs instead:
    SomeAppName::Api.ssl_cert_bundle = :bundled
  On failure reading specified bundle, raises exception instead of warning

#### 3.1.0

- Add .bulk_update and bulk_update!

#### 3.0.0

BREAKING CHANGES
- Update has_many, belongs_to signatures
- Rename Base#url -> #resource_path
- Drop ActiveModel <= 4.1
- `#errors` is now always an ActiveModel::Errors instance

DEPRECATION NOTICE
- ValidationError is deprecated and will be removed in 3.1.

Other changes
- Add :cache option for requests
  Set default store at MyApi::Api.cache_store=
    See example railtie.rb for auto-config
  Examples:
    SomeResource.all(cache: true)
      uses MyApi::Api.cache_store
    SomeResource.find(id, cache: {expires_in: 5.minutes})
      uses MyApi::Api.cache_store with specified options
    SomeResource.find(id, cache: Dalli::Store.new(...))
      uses provided cache store (with its default options)
- Make bearer_credential_key allow strings or symbols
- Warn on attr name collision
- Update CA certificates
- Better default output for #as_json
- Allow ActiveModel/Support 6.0
- Resolve deprecation messages on Ruby 2.6
- Add #factory
- API response :errors may be hash or array
- Add RecordInvalid#errors
- Better Ruby and ActiveModel integration
  - #eql?, #==, #hash
  - #model_name
  - #i18n_scope, config via Api.i18n_scope=
  - #cache_key, #cache_version, #cache_key_with_version

#### 2.3.3

- Improve keepalive handling

#### 2.3.2

- Allow ActiveSupport 7.0

#### 2.3.1

- Allow ActiveModel 6.1

#### 2.3.0

- Use system's CA certificate store by default (backport from v3.2.0)
  To use bundled CAs instead:
    SomeAppName::Api.ssl_cert_bundle = :bundled
  On failure reading specified bundle, raises exception instead of warning

#### 2.2.2

- Update certs

#### 2.2.1

- Fix decimal attributes on Ruby <= 2.5.x

#### 2.2.0

- Allow ActiveSupport 6.0
- Resolve deprecation messages on Ruby 2.6

#### 2.1.2

- Fix URL processing when frozen

#### 2.1.1

- Allow ActiveSupport 5.2

#### 2.1.0

- Add ability to produce Authorization headers

#### 2.0.8

- Properly handle grandchild credentials objects

#### 2.0.7

- Accept ActionController::Parameters objects as attribute params

#### 2.0.6

- Allow ActiveSupport 5.1

#### 2.0.5

- Fix handling of missing detailed error messages

#### 2.0.4

- Better handle network error

#### 2.0.3

- Fix incorrect dependency on MultiJson

#### 2.0.2

- Resource.new now handles credentials: {} as part of attribute hash
  Brings parity with other resource methods

#### 2.0.1

- Add .bulk_delete and bulk_delete!
- Handle 215 response code
- Better handle network error

#### 2.0.0

- NOTE: This version includes breaking changes.
- Change params and credentials parsing
  This changes the signatures for request() and all crud methods:
    request(method, url, credentials, params, headers)
      => request(method, url, params: {}, headers: {}, credentials: {})
    all(), find(), create(), update(), delete(), etc
      => pass credentials: {} instead of the final api_creds param
- find(nil) now raises RecordNotFound instead of returning nil
- Make <:assoc>_id=() writers private; shouldn't have been exposed to begin with.
- Treat 409 like 422 and add error messages instead of raising an exception.
- Add default error message for 409,422 if none received.
- Make MultiJson optional - use it if present, otherwise default to stdlib JSON.
  If using MultiJson, requires v1.9+.
- Improve header handling for requests
- Add #update!(), #delete!()
- Add AccountInactive exception for 402 errors

#### 1.2.1

- Connection errors should raise NCore::ConnectionError

#### 1.2.0

- Add delete association methods

#### 1.1.0

- Fix compatibility with ActiveModel 4.2

#### 1.0.0

- Initial release
