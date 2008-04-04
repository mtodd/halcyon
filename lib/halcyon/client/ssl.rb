require 'net/https'

module Halcyon
  class Client
    private
    
    def request(req, headers={})
      # set default headers
      req["Content-Type"] = CONTENT_TYPE
      req["User-Agent"] = USER_AGENT
      
      # apply provided headers
      headers.each do |(header, value)|
        req[header] = value
      end
      
      # provide hook for modifying the headers
      req = headers(req) if respond_to? :headers
      
      # prepare and send HTTPS request
      serv = Net::HTTP.new(@uri.host, @uri.port)
      serv.use_ssl = true if @uri.scheme == 'https'
      res = serv.start {|http|http.request(req)}
      
      # parse response
      body = JSON.parse(res.body).to_mash
      
      # handle non-successes
      if @options[:raise_exceptions] && !res.kind_of?(Net::HTTPSuccess)
        raise self.class.const_get(Exceptions::HTTP_STATUS_CODES[body[:status]].tr(' ', '_').camel_case.gsub(/( |\-)/,'')).new
      end
      
      # return response
      body
    rescue Halcyon::Exceptions::Base => e
      # log exception if logger is in place
      raise
    end
    
  end
end
