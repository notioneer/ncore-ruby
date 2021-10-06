module NCore
  module Exceptions
    extend ActiveSupport::Concern

    included do
      class_eval <<-INCL, __FILE__, __LINE__+1
        class Error < StandardError ; end

        class AccessDenied < Error ; end
        class AccountInactive < Error ; end
        class AuthenticationFailed < Error ; end
        class CertificateError < Error ; end
        class ConnectionError < Error ; end
        class RateLimited < Error ; end
        class RecordNotFound < Error ; end
        class UnsavedObjectError < Error ; end

        class RecordError < Error
          attr_reader :object

          def initialize(object, msg: nil)
            @object = object
            msg ||= "Error on \#{class_name_for(object)}"
            super msg
          end

          def errors
            object&.errors
          end

          private

          def class_name_for(object)
            n   = object.class_name if object.respond_to?(:class_name)
            n ||= object.class.class_name if object.class.respond_to?(:class_name)
            n ||= object.name if object.respond_to?(:name)
            n ||= object.class.name
          end
        end

        class RecordInvalid < RecordError
          def initialize(object)
            msg = "\#{class_name_for(object)} Invalid: \#{object.errors.to_a.join(' ')}"
            super object, msg: msg
          end
        end

        class WaitTimeout < RecordError
          def initialize(object)
            msg = "Timeout waiting for condition on \#{class_name_for(object)}"
            super object, msg: msg
          end
        end

        class QueryError < Error
          attr_reader :errors

          def initialize(errors)
            @errors = errors
            msg = "Error: \#{errors.to_a.join(' ')}"
            super msg
          end
        end

        class BulkActionError < QueryError ; end
      INCL
    end

  end
end
