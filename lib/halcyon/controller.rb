module Halcyon
  
  # The base controller providing methods application controllers will need.
  class Controller
    include Exceptions
    
    attr_accessor :env
    attr_accessor :request
    attr_accessor :session
    attr_accessor :cookies
    
    # Sets the <tt>@env</tt> and <tt>@request</tt> instance variables, used by
    # various helping methods.
    #   +env+ the request environment details
    # 
    def initialize(env)
      @env = env
      @request = Rack::Request.new(@env)
    end
    
    # Used internally.
    # 
    # Dispatches the action specified, including all filters.
    # 
    def _dispatch(action)
      _run_filters(:before, action)
      response = send(action)
      _run_filters(:after, action)
      response
    end
    
    # Returns the request params and the route params.
    # 
    # Returns Hash:{route_params, get_params, post_params}.to_mash
    # 
    def params
      self.request.params.merge(self.env['halcyon.route']).to_mash
    end
    
    # Returns any POST params, excluding GET and route params.
    # 
    # Returns Hash:{...}.to_mash
    # 
    def post
      self.request.POST.to_mash
    end
    
    # Returns any GET params, excluding POST and route params.
    # 
    # Returns Hash:{...}.to_mash
    # 
    def get
      self.request.GET.to_mash
    end
    
    # Returns query params (usually the GET params).
    # 
    # Returns Hash:{...}.to_mash
    # 
    def query_params
      Rack::Utils.parse_query(self.env['QUERY_STRING']).to_mash
    end
    
    # The path of the request URL.
    # 
    # Returns String:/path/of/request
    # 
    def uri
      # special parsing is done to remove the protocol, host, and port that
      # some Handlers leave in there. (Fixes inconsistencies.)
      URI.parse(self.env['REQUEST_URI'] || self.env['PATH_INFO']).path
    end
    
    # The request method.
    # 
    # Returns Symbol:get|post|put|delete
    # 
    def method
      self.env['REQUEST_METHOD'].downcase.to_sym
    end
    
    # Formats message into the standard success response hash, with a status of
    # 200 (the standard success response).
    #   +body+ the body of the response
    # 
    # The <tt>body</tt> defaults to <tt>String:"OK"</tt> but can be anything,
    # including hashes, arrays, and literal values.
    # 
    # Alternatively, if you choose to modify the message format, add a key in
    # addition to <tt>:status</tt> and <tt>:body</tt>. For example:
    # <tt>{:status=>200,:body=>'OK', :stats=>[...], :receipt=>...}</tt>
    # 
    # Changes to this method described above should be reflected for in the
    # clients as well.
    # 
    # Aliases
    #   <tt>success</tt>
    # 
    # Returns Hash:{:status=>200, :body=>body}
    # 
    def ok(body='OK')
      {:status => 200, :body => body}
    end
    alias_method :success, :ok
    
    # Formats message into the standard response hash, with a status of 404
    # (the standard "Not Found" response value).
    #   +body+ the body of the response
    # 
    # The <tt>body</tt> defaults to <tt>String:"Not Found"</tt> but can be
    # anything, including hashes, arrays, and literal values. However, it is
    # strongly discouraged since the <tt>body</tt> should simply describe the
    # problem with processing their request.
    # 
    # Alternatively, if you choose to modify the message format, add a key in
    # addition to <tt>:status</tt> and <tt>:body</tt>. For example:
    # <tt>{:status=>404,:body=>'Not Found', :suggestions=>[...]}</tt>
    # 
    # Changes to this method described above should be reflected for in the
    # clients as well.
    # 
    # Aliases
    #   <tt>missing</tt>
    # 
    # Returns Hash:{:status=>404, :body=>body}
    # 
    def not_found(body='Not Found')
      {:status => 404, :body => body}
    end
    alias_method :missing, :not_found
    
    # Returns the name of the controller in path form.
    # 
    def self.controller_name
      @controller_name ||= self.name.to_const_path
    end
    
    # Returns the name of the controller in path form.
    # 
    def controller_name
      self.class.controller_name
    end
    
    # Generates a URL based on the given name and passed
    # options. Used with named routes and resources:
    #
    #  url(:users) # => "/users"
    #  url(:admin_permissons) # => "/admin/permissions"
    #  url(:user, @user) # => "/users/1"
    #
    # Based on the identical method of Merb's controller.
    # 
    def url(name, rparams={})
      Halcyon::Application::Router.generate(name, rparams,
        { :controller => controller_name,
          :action => method
        }
      )
    end
    
    #--
    # Filters
    #++
    
    class << self
      
      # Creates +filters+ accessor method and initializes the +@filters+
      # attribute with the necessary structure.
      # 
      def filters
        @filters ||= {:before => [], :after => []}
      end
      
      # Sets up filters for the method defined in the controllers.
      # 
      # Examples
      # 
      #   class Foos < Application
      #     before :foo do
      #       #
      #     end
      #     after :blah, :only => [:foo]
      #     def foo
      #       # the block is called before the method is called
      #       # and the method is called after the method is called
      #     end
      #     private
      #     def blah
      #       #
      #     end
      #   end
      # 
      # Options
      # * +method_or_filter+ either the method to run before 
      # 
      def before method_or_filter, options={}, &block
        _add_filter(:before, method_or_filter, options, block)
      end
      
      # See documentation for the +before+ method.
      # 
      def after method_or_filter, options={}, &block
        _add_filter(:after, method_or_filter, options, block)
      end
      
      # Used internally to save the filters, applied when called.
      # 
      def _add_filter(where, method_or_filter, options, block)
        self.filters[where] << [method_or_filter, options, block]
      end
      
    end
    
    # Used internally.
    # 
    # Applies the filters defined by the +before+ and +after+ class methods.
    # 
    # +where+ specifies whether to apply <tt>:before</tt> or <tt>:after</tt>
    #   filters
    # +action+ the routed action (for testing filter applicability)
    # 
    def _run_filters(where, action)
      self.class.filters[where].each do |(method_or_filter, options, block)|
        if block
          block.call(self) if _filter_condition_met?(method_or_filter, options, action)
        else
          send(method_or_filter) if _filter_condition_met?(method_or_filter, options, action)
        end
      end
    end
    
    # Used internally.
    # 
    # Tests whether a filter should be run for an action or not.
    # 
    def _filter_condition_met?(method_or_filter, options, action)
      (
        options[:only] and options[:only].include?(action)) or
        (options[:except] and !options[:except].include?(action)
      ) or (
        method_or_filter == action
      )
    end
    
  end
  
end
