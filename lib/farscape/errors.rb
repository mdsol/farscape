require 'active_support/core_ext/string/filters'

module Farscape
  module Exceptions
    class ProtocolException < IOError
      attr_reader :representor

      def initialize(representor)
        @representor = representor
      end

      def message
        @representor.representor.to_hash
      end

      def error_description
        'Unknown Error'
      end
    end
    
    #4xx
    class BadRequest < ProtocolException
      def error_description
        'The request could not be understood by the server due to malformed syntax. The client SHOULD NOT repeat the request without modifications.'
      end
    end
    class Unauthorized < ProtocolException
      def error_description
        'The request requires user authentication.
        The client MAY repeat the request with suitable Authorization.
        If the request already included Authorization credentials,
        then the response indicates that authorization has been refused for those credentials.'.squish
      end
    end
    class Forbidden < ProtocolException
      def error_description
        'The server understood the request, but is refusing to fulfill it.
        Authorization will not help and the request SHOULD NOT be repeated.'.squish
      end
    end
    class NotFound < ProtocolException
      def error_description
        'The server has not found anything matching the Request-URI.
        No indication is given of whether the condition is temporary or permanent.
        This status code is commonly used when the server does not wish to reveal exactly why the request has been refused, or when no other response is applicable.'.squish
      end
    end
    class MethodNotAllowed < ProtocolException
      def error_description
        'The protocol method specified in the Request-Line is not allowed for the resource identified by the Request-URI.'
      end
    end
    class NotAcceptable < ProtocolException
      def error_description
        'The resource identified by the request is only capable of generating response entities which have content characteristics not acceptable according to the accept headers sent in the request.'
      end
    end
    class ProxyAuthenticationRequired < ProtocolException
      def error_description
        'The client must first authenticate itself with the proxy.
        The client MAY repeat the request with suitable Proxy Authorization.'.squish
      end
    end
    class RequestTimeout < ProtocolException
      def error_description
        'The client did not produce a request within the time that the server was prepared to wait.
        The client MAY repeat the request without modifications at any later time.'.squish
      end
    end
    class Conflict < ProtocolException
      def error_description
        'The request could not be completed due to a conflict with the current state of the resource.
        This code is only allowed in situations where it is expected that the user might be able to resolve the conflict and resubmit the request.
        Conflicts are most likely to occur in response to an idempotent request.
        For example, if versioning were being used and the entity included changes to a resource which conflict with those made by an earlier (third-party) request'.squish
      end
    end
    class Gone < ProtocolException
      def error_description
        'The requested resource is no longer available at the server and no forwarding address is known.
        This condition is expected to be considered permanent.
        Clients with link editing capabilities SHOULD delete references to the Request-URI after user approval.
        This response is cacheable unless indicated otherwise.'.squish
      end
    end
    class LengthRequired < ProtocolException
      def error_description
        'The server refuses to accept the request without a defined content length.'
      end
    end
    class PreconditionFailed < ProtocolException
      def error_description
        'The precondition given by the client evaluated to false when it was tested on the server.'
      end
    end
    class RequestEntityTooLarge < ProtocolException
      def error_description
        'The server is refusing to process a request because the request entity is larger than the server is willing or able to process.'.squish
      end
    end
    class RequestUriTooLong < ProtocolException
      def error_description
        'The server is refusing to service the request because the Request-URI is longer than the server is willing to interpret.'
        end
    end
    class UnsupportedMediaType < ProtocolException
      def error_description
        'The server is refusing to service the request because the entity of the request is in a format not supported by the requested resource for the requested method.'
      end
    end
    class RequestedRangeNotSatisfiable < ProtocolException
      def error_description
        'A request requested a resource within a range,
        and none of the range-specifier values in this field overlap the current extent of the selected resource,
        and the request did not specify range conditions.'.squish
      end
    end
    class ExpectationFailed < ProtocolException
      def error_description
        'The expectation given by the client could not be met by this server.
        If the server is a proxy, the server has unambiguous evidence that the request could not be met by the next-hop server.'.squish
      end
    end
    class ImaTeapot < ProtocolException
      def error_description
        'The server is a teapot; the resulting entity body may be short and stout.
        Demonstrations of this behaviour exist.'.squish
      end
    end

    class UnprocessableEntity < ProtocolException
      def error_description
        'The request was well-formed but was unable to be followed due to semantic errors.'.squish
      end
    end

    #5xx
    class InternalServerError < ProtocolException
      def error_description
        'The server encountered an unexpected condition which prevented it from fulfilling the request.'
      end
    end
    class NotImplemented < ProtocolException
      def error_description
        'The server does not support the functionality required to fulfill the request.'
      end
    end
    class BadGateway < ProtocolException
      def error_description
        'The server received an invalid response from the upstream server it accessed in attempting to fulfill the request.'
      end
    end
    class ServiceUnavailable < ProtocolException
      def error_description
        'The server is currently unable to handle the request due to a temporary overloading or maintenance of the server.
        The implication is that this is a temporary condition which will be alleviated after some delay.'.squish
      end
    end
    class GatewayTimeout < ProtocolException
      def error_description
        'The server did not receive a timely response from an upstream server specified it needed to access in attempting to complete the request.'
      end
    end
    class ProtocolVersionNotSupported < ProtocolException
      def error_description
        'The server does not support, or refuses to support, the protocol or protocol version that was used in the request message.
        The server is indicating that it is unable or unwilling to complete the request using the same protocol as the client'.squish
      end
    end

  end
end
