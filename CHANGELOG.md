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
