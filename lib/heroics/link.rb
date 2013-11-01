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
    # @param options [Hash] Configuration for the link.  Possible keys
    #   include:
    #   - default_headers: Optionally, a set of headers to include in every
    #     request made by the client.  Default is no custom headers.
    #   - cache: Optionally, a Moneta-compatible cache to store ETags.
    #     Default is no caching.
    def initialize(url, path, method, options={})
      @url = url
      @path = path
      @method = method
      @default_headers = options[:default_headers] || {}
      @cache = options[:cache] || Moneta.new(:Null)
    end

    # Make a request to the server.
    #
    # JSON content received with an ETag is cached.  When the server returns a
    # 304 Not Modified content is loaded and returned from the cache.  The
    # cache considers headers, in addition to the URL path, when creating keys
    # so that requests to the same path, such as for paginated results, don't
    # cause cache collisions.
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
      headers = @default_headers
      if body
        headers = headers.merge({'Content-Type' => 'application/json'})
        body = MultiJson.dump(body)
      end
      cache_key = "#{path}:#{headers.hash}"
      if @method == :get
        etag = @cache["etag:#{cache_key}"]
        headers = headers.merge({'If-None-Match' => etag}) if etag
      end

      connection = Excon.new(@url)
      response = connection.request(method: @method, path: path,
                                    headers: headers, body: body,
                                    expects: [200, 201, 304])
      content_type = response.headers['Content-Type']
      if response.status == 304
        MultiJson.load(@cache["data:#{cache_key}"])
      elsif content_type && content_type.include?('application/json')
        etag = response.headers['ETag']
        if etag
          @cache["etag:#{cache_key}"] = etag
          @cache["data:#{cache_key}"] = response.body
        end
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
