#--
#  Created by Matt Todd on 2007-12-14.
#  Copyright (c) 2007. All rights reserved.
#++

#--
# module
#++

module Halcyon
  module Exceptions #:nodoc:
    HTTP_ERROR_CODES = {
      403 => "Forbidden",
      404 => "Not Found",
      406 => "Not Acceptable",
      415 => "Unsupported Media Type"
    }
  end
end
