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

        class RecordInvalid < Error
          attr_reader :object

          def initialize(object)
            @object = object
            cl_name = object.class_name if object.respond_to?(:class_name)
            cl_name ||= object.class.class_name if object.class.respond_to?(:class_name)
            cl_name ||= object.name if object.respond_to?(:name)
            cl_name ||= object.class.name
            msg = "\#{cl_name} Invalid: \#{@object.errors.to_a.join(' ')}"
            super msg
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
        class ValidationError < QueryError ; end
      INCL
    end

  end
end
