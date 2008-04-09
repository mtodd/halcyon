module Halcyon
  
  # Included into Halcyon::Application in order to provide exception classes
  # like NotModified, OK, Forbidden, or NotFound to simplify generating error
  # methods and handling specific error instances.
  # 
  # It is not intended for these exceptions to be destructive or process-ending
  # in the least, only to simplify finishing up processing and relaying
  # appropriate status to the caller/client.
  # 
  # These classes inherit from StandardError because it is convenient to raise
  # a given status and let Halcyon's dispatcher handle sending the message to
  # the client, but it is possible to just instantiate an object without
  # throwing an exception if necessary.
  module Exceptions #:nodoc:
    
    #--
    # Base Halcyon Exception
    #++
    
    class Base < StandardError #:nodoc:
      attr_accessor :status, :body
      def initialize(status, body)
        @status = status
        @body = body
        super "[#{@status}] #{@body}"
      end
    end
    
    #--
    # HTTP Status Codes and Errors
    #++
    
    HTTP_STATUS_CODES = {
      100  => 'Continue',
      101  => 'Switching Protocols',
      200  => 'OK',
      201  => 'Created',
      202  => 'Accepted',
      203  => 'Non-Authoritative Information',
      204  => 'No Content',
      205  => 'Reset Content',
      206  => 'Partial Content',
      300  => 'Multiple Choices',
      301  => 'Moved Permanently',
      302  => 'Moved Temporarily',
      303  => 'See Other',
      304  => 'Not Modified',
      305  => 'Use Proxy',
      400  => 'Bad Request',
      401  => 'Unauthorized',
      402  => 'Payment Required',
      403  => 'Forbidden',
      404  => 'Not Found',
      405  => 'Method Not Allowed',
      406  => 'Not Acceptable',
      407  => 'Proxy Authentication Required',
      408  => 'Request Time-out',
      409  => 'Conflict',
      410  => 'Gone',
      411  => 'Length Required',
      412  => 'Precondition Failed',
      413  => 'Request Entity Too Large',
      414  => 'Request-URI Too Large',
      415  => 'Unsupported Media Type',
      500  => 'Internal Server Error',
      501  => 'Not Implemented',
      502  => 'Bad Gateway',
      503  => 'Service Unavailable',
      504  => 'Gateway Time-out',
      505  => 'HTTP Version not supported'
    }
    
    #--
    # Classify Status Codes
    #++
    
    HTTP_STATUS_CODES.to_a.each do |http_status|
      status, body = http_status
      class_eval <<-"end;"
        class #{body.gsub(/( |\-)/,'')} < Halcyon::Exceptions::Base
          def initialize(s=#{status}, b='#{body}')
            super
          end
        end
      end;
    end
    
  end
end
