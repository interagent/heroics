module Heroics
  # A link invokes requests with an HTTP server.
  class Link
    # Instantiate a link.
    #
    # @param url [String] The URL to use when making requests.  Include the
    #   username and password to use with HTTP basic auth.
    # @param path [String] The path to use when making requests.  Substrings
    #   that match `{(#/name)}` are replaced with user provided values when
    #   the link is invoked.
    # @param method [Symbol] A symbol representing the HTTP method to use when
    #   invoking the link.
    def initialize(url, path, method)
      @url = url
      @path = path
      @method = method
    end

    # Make a request to the server.
    #
    # @param parameters [Array] The list of parameters to inject into the
    #   path.  A request body can be passed as the final parameter and will
    #   always be converted to JSON before being transmitted.
    # @raise [ArgumentError] Raised if either too many or too few parameters
    #   were provided.
    # @return [String,Object] A string for text responses or an object for
    #   JSON responses.
    def run(*parameters)
      path, body = format_path(parameters)
      connection = Excon.new(@url)
      if body
        headers = {'Content-Type' => 'application/json'}
        body = MultiJson.dump(body)
      end
      response = connection.request(method: @method, path: path,
                                    headers: headers, body: body,
                                    expects: [200, 201])
      content_type = response.headers['Content-Type']
      # FIXME Correctly handle unsuccessful HTTP status codes. -jkakar
      if content_type && content_type.include?('application/json')
        MultiJson.load(response.body)
      elsif !response.body.empty?
        response.body
      end
    end

    private

    # Inject parameters into the path and return the body, if it exists.
    #
    # @param parameters [Array] The list of parameters to inject into the
    #   path.
    # @raise [ArgumentError] Raised if either too many or too few parameters
    #   were provided.
    # @return [String,Object] A path and request body pair.  The body value is
    #   nil if a payload wasn't included in the list of parameters.
    def format_path(parameters)
      parameter_regex = /\{\([%\/a-zA-Z0-9]*\)\}/
      parameter_size = @path.scan(parameter_regex).size
      too_few_parameters = parameter_size > parameters.size
      # FIXME We should use the schema to detect when a request body is
      # permitted and do the calculation correctly here. -jkakar
      too_many_parameters = parameter_size < (parameters.size - 1)
      if too_few_parameters || too_many_parameters
        raise ArgumentError.new("wrong number of arguments " +
                                "(#{parameters.size} for #{parameter_size})")
      end
      path = @path
      (0..parameter_size).each do |i|
        path = path.sub(parameter_regex, format_parameter(parameters[i]))
      end
      body = parameters.slice(parameter_size)
      return path, body
    end

    # Convert a path parameter to a format suitable for use in a path.
    #
    # @param [Fixnum,String,TrueClass,FalseClass,Time] The parameter to format.
    # @return [String] The formatted parameter.
    def format_parameter(parameter)
      parameter.instance_of?(Time) ? iso_format(parameter) : parameter.to_s
    end

    # Convert a time to an ISO 8601 combined data and time format.
    #
    # @param time [Time] The time to convert to ISO 8601 format.
    # @return [String] An ISO 8601 date in `YYYY-MM-DDTHH:MM:SSZ` format.
    def iso_format(time)
      time.getutc.strftime('%Y-%m-%dT%H:%M:%SZ')
    end
  end
end
