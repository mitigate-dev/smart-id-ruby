# SmartId

This gem provides a wrapper around [Smart ID API](https://github.com/SK-EID/smart-id-documentation]). All the necessary checks, listed in point 3.5 are implemented. Currently this gem only supports authentication actions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'smart_id', "~> 0.1"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install smart_id

## Usage

### Configuration

configuration can be done, by creating an initializer file and loading it before the application starts.

```ruby
SmartId.configure do |config|
    config.relying_party_uuid = "MySmartIdUUID"
    config.relying_party_name = "My Smart ID name"
    config.environment = "demo" # possible options ar "demo" and "production", uses according smart-id parameters and keys
    config.default_certificate_level = "ADVANCED" # Possible options are "ADVANCED" or "QUALIFIED". Defaults to "ADVANCED"
    config.poller_timeout_secods = 10 # seconds to wait when fetching authentication confirmation
end

```
### Authentication types

Authentication can be done either with providing user's national identity number or an identity document number

For national identity number use
```ruby
SmartId::Api::Authentication::IdentityNumber
```

For document number use
```ruby
SmartId::Api::Authentication::Document
```
Smart ID authentication is done in 2 steps - **initializing the authentication** and then **getting confimation from Smart ID** service. Those two steps happen asynchronously, so some parameters should be persisted either in session storage or in database

* Back-end initializes authentification - user can see verification code on the app, and receives smart ID request to input PIN in they're mobile 

* Back-end authenfication confirmation - check whether user has authenticated by correctly typing in they're PIN on the mobile device

## Authentication Request

To initialize authentication make a controller action. 

#### National identity number

```ruby
class UserController < AplicationController
    #...
    def authenticate_smart_id
        # authentication hash by default will generate random bytes, that will be hashed for signature check
        # if you wish to provide your own randomization, you can pass a parameter to AuthenticationHash with the random string
        # authentication_hash = SmartId::Utils::AuthenticationHash.new(SecureRandom.hex(64))
        # each authentication should have a unique random string passed
        authentication_hash = SmartId::Utils::AuthenticationHash.new

        auth_response = SmartId::Api::Authentication::IdentityNumber.authenticate(
            country: params[:country], # 2 character ISO 3166-1 alpha-2 format(for example EE, LT, LV, KZ)
            identity_number: params[:identity_number],
            authentication_hash: authentication_hash
        )

        session[:smart_id_session] = auth_response.session_id
        session[:auth_hash] = authentication_hash.hash_data

        # Screen/page after this call should show the user verification code, to see if it matches
        # the one they see on their mobile device
        render json: { verification_code: auth_response.verification_code }

    end
    #...
end

```

#### Document number

```ruby
class UserController < AplicationController
    #...
    def authenticate_smart_id
        # authentication hash by default will generate random bytes, that will be hashed for signature check
        # if you wish to provide your own randomization, you can pass a parameter to AuthenticationHash with the random string
        # authentication_hash = SmartId::Utils::AuthenticationHash.new(SecureRandom.hex(64))
        # each authentication should have a unique random string passeds
        authentication_hash = SmartId::Utils::AuthenticationHash.new

        auth_response = SmartId::Api::Authentication::Document.authenticate(
            document_number: params[:document_number],
            authentication_hash: authentication_hash
        )

        session[:smart_id_session] = auth_response.session_id
        session[:auth_hash] = authentication_hash.hash_data

        # Screen/page after this call should show the user verification code, to see if it matches
        # the one they see on their mobile device
        render json: { verification_code: auth_response.verification_code }

    end
    #...
end

```

## Authentication Confirmation
Create another controller action

```ruby
class UserController < AplicationController
    #...
    def confirm_smart_id
        # use hash_data saved on authentication initialization as parameter
        authentication_hash = SmartId::Utils::AuthenticationHash.new(session[:auth_hash])

        confirmation_response = SmartId::Api::Authentication::ConfirmationPoller.confirm(
            session_id: session[:smart_id_session],
            authentication_hash: authentication_hash,
            # if true, will continously make requests to smart-id and return only after verification is completed
            # you can set this parameter to false, to handle polling yourself
            poll: true # default - true 
        )
    end
    #...
end 
```


## Response structure

confirmation response will have the following attributes
```ruby 
authentication_hash = SmartId::Utils::AuthenticationHash.new(session[:auth_hash])

confirmation_response = SmartId::Api::Authentication::ConfirmationPoller.confirm(
    session_id: session[:smart_id_session],
    authentication_hash: authentication_hash,
    # if true, will continously make requests to smart-id and return only after verification is completed
    # you can set this parameter to false, to handle polling yourself
    poll: true # default - true 
)

confirmation_response.confirmation_running? # => true/false whether the user has finished authentication. Relevant, only if polling is not handled by the gem (with `poll` parameter set to false)
confirmation_response.end_result  # => end result of the verification. possible values are "OK"/"USER_REFUSED"/"TIMEOUT"/"DOCUMENT_UNUSABLE", see details in https://github.com/SK-EID/smart-id-documentation#5-session-end-result-codes
confirmation_response.document_number #=> document number for user
confirmation_response.certificate_level #=> certificate level for user - values are "ADVANCED" or "QUALIFIED"

confirmation_response.certificate.content.given_name #=> given name for user
confirmation_response.certificate.content.surname #=> surname for user
confirmation_response.certificate.content.serial_number #=> string, that includes user's national identity number

```

## Customization options
You can provide extra parameters when initializing authentication (for both - identity number and document)

```ruby
SmartId::Api::Authentication::Document.authenticate(
    document_number: "", # REQUIRED - document number
    authentication_hash: obj, # REQUIRED - authentification hash object of SmartId::Utils::AuthenticationHash
    certificate_level: "", # OPTIONAL - Either "ADVANCED" or "QUALIFIED" - if none are provided, default certificate level is used
    display_text: nil, # OPTIONAL - Text that user will see on their mobile device when asked for authentication
    multiple_choice: false, # OPTIONAL - If true, user will be asked to choose the correct verification code from supplied options on their device
)

SmartId::Api::Authentication::IdentityNumber.authenticate(
    country: "", # REQUIRED - 2 character ISO 3166-1 alpha-2 format(for example EE, LT, LV, KZ)
    identity_number: "", # REQUIRED - natioanl identity number
    authentication_hash: obj, # REQUIRED - authentification hash object of SmartId::Utils::AuthenticationHash
    certificate_level: "", # OPTIONAL - Either "ADVANCED" or "QUALIFIED" - if none are provided, default certificate level is used
    display_text: nil, # OPTIONAL - Text that user will see on their mobile device when asked for authentication
    multiple_choice: false, # OPTIONAL - If true, user will be asked to choose the correct verification code from supplied options on their device
)
```

## Exceptions
All exceptions inherit from `SmartId::Exception`

* `SmartId::InvalidParamsError` - either country or identity_number were not provided when trying to authenticate with identity number
* `SmartId::ConnectionError` - authentication/confirmation request failed
* `SmartId::SSLCertificateNotVerified` - SSL certificate for smart ID service was not verified. Check for newest version of this gem to always keep cerficates updated
* `SmartId::InvalidResponseCertificate` - Certificate used in confirmation response is invalid
* `SmartId::InvalidResponseSignature` - Signature used in confirmation response is invalid.
* `SmartId::IncorrectAccountLevelError` - User's Smart ID account is below the required level by the authentication request ( "ADVANCED" < "QUALIFIED")

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/smart_id.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
