# frozen_string_literal: true
module Heroics
  # A link invokes requests with an HTTP server.
  class Link
    # Instantiate a link.
    #
    # @param url [String] The URL to use when making requests.  Include the
    #   username and password to use with HTTP basic auth.
    # @param link_schema [LinkSchema] The schema for this link.
    # @param options [Hash] Configuration for the link.  Possible keys
    #   include:
    #   - default_headers: Optionally, a set of headers to include in every
    #     request made by the client.  Default is no custom headers.
    #   - cache: Optionally, a Moneta-compatible cache to store ETags.
    #     Default is no caching.
    def initialize(url, link_schema, options={})
      @root_url, @path_prefix = unpack_url(url)
      @link_schema = link_schema
      @default_headers = options[:default_headers] || {}
      @cache = options[:cache] || {}
    end

    # Make a request to the server.
    #
    # JSON content received with an ETag is cached.  When the server returns a
    # *304 Not Modified* status code content is loaded and returned from the
    # cache.  The cache considers headers, in addition to the URL path, when
    # creating keys so that requests to the same path, such as for paginated
    # results, don't cause cache collisions.
    #
    # When the server returns a *206 Partial Content* status code the result
    # is assumed to be an array and an enumerator is returned.  The enumerator
    # yields results from the response until they've been consumed at which
    # point, if additional content is available from the server, it blocks and
    # makes a request to fetch the subsequent page of data.  This behaviour
    # continues until the client stops iterating the enumerator or the dataset
    # from the server has been entirely consumed.
    #
    # @param parameters [Array] The list of parameters to inject into the
    #   path.  A request body can be passed as the final parameter and will
    #   always be converted to JSON before being transmitted.
    # @raise [ArgumentError] Raised if either too many or too few parameters
    #   were provided.
    # @return [String,Object,Enumerator] A string for text responses, an
    #   object for JSON responses, or an enumerator for list responses.
    def run(*parameters)
      path, body = @link_schema.format_path(parameters)
      path = "#{@path_prefix}#{path}" unless @path_prefix == '/'
      headers = @default_headers
      if body
        case @link_schema.method
        when :put, :post, :patch
          headers = headers.merge({'Content-Type' => @link_schema.content_type})
          body = @link_schema.encode(body)
        when :get, :delete
          if body.is_a?(Hash)
            query = body
          else
            query = MultiJson.load(body)
          end
          body = nil
        end
      end

      connection = Excon.new(@root_url, thread_safe_sockets: true)
      response = request_with_cache(connection,
                                    method: @link_schema.method, path: path,
                                    headers: headers, body: body, query: query,
                                    expects: [200, 201, 202, 204, 206])
      content_type = response.headers['Content-Type']
      if content_type && content_type =~ /application\/.*json/
        body = MultiJson.load(response.body)
        if response.status == 206
          next_range = response.headers['Next-Range']
          Enumerator.new do |yielder|
            while true do
              # Yield the results we got in the body.
              body.each do |item|
                yielder << item
              end

              # Only make a request to get the next page if we have a valid
              # next range.
              break unless next_range
              headers = headers.merge({'Range' => next_range})
              response = request_with_cache(connection,
                                            method: @link_schema.method,
                                            path: path, headers: headers,
                                            expects: [200, 201, 206])
              body = MultiJson.load(response.body)
              next_range = response.headers['Next-Range']
            end
          end
        else
          body
        end
      elsif !response.body.empty?
        response.body
      end
    end

    private

    def request_with_cache(connection, options)
      options[:expects] << 304
      cache_key = "#{options[:path]}:#{options[:headers].hash}"
      if options[:method] == :get
        etag = @cache["etag:#{cache_key}"]
        options[:headers] = options[:headers].merge({'If-None-Match' => etag}) if etag
      end
      response = connection.request(options)

      if response.status == 304
        body = @cache["data:#{cache_key}"]
        status = @cache["status:#{cache_key}"]
        headers = @cache["headers:#{cache_key}"]
        CachedResponse.new(status, body, headers)
      else
        if etag = response.headers['ETag']
          @cache["etag:#{cache_key}"] = etag
          @cache["data:#{cache_key}"] = response.body
          @cache["status:#{cache_key}"] = response.status
          @cache["headers:#{cache_key}"] = response.headers
        end
        response
      end
    end

    # Unpack the URL and split it into a root URL and a path prefix, if one
    # exists.
    #
    # @param url [String] The complete base URL to use when making requests.
    # @return [String,String] A (root URL, path) prefix pair.
    def unpack_url(url)
      root_url = []
      path_prefix = ''
      parts = URI.split(url)
      root_url << "#{parts[0]}://"
      root_url << "#{parts[1]}@" unless parts[1].nil?
      root_url << "#{parts[2]}"
      root_url << ":#{parts[3]}" unless parts[3].nil?
      path_prefix = parts[5]
      return root_url.join(''), path_prefix
    end

    class CachedResponse
      attr_reader :status, :body, :headers
      def initialize(status, body, headers)
        @status = status
        @body = body
        @headers = headers
      end
    end

  end
end
