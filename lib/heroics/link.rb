module Heroics
  # A representation of a link that can be invoked to make a request to a
  # service and return a response.
  class Link
    def initialize(url, path, method)
      @url = url
      @path = path
      @method = method
    end

    def run(*parameters)
      path, body = format_path(parameters)
      connection = Excon.new(@url)
      response = connection.get(path: path)
      if response.headers['Content-Type'] == 'application/json;charset=utf-8'
        MultiJson.load(response.body)
      elsif !response.body.empty?
        response.body
      end
    end

    private

    def format_path(parameters)
      parameter_regex = /\{\(\#[\/a-zA-Z0-9]*\)\}/
      parameter_size = @path.scan(parameter_regex).size
      path = @path
      (0..parameter_size).each do |i|
        path = path.sub(parameter_regex, format_parameter(parameters[i]))
      end
      remaining_parameters = parameters.slice(parameter_size)
      body = remaining_parameters.first if remaining_parameters
      return path, body
    end

    def format_parameter(parameter)
      parameter.instance_of?(Time) ? iso_format(parameter) : parameter.to_s
    end

    # Convert a time to an ISO 8601 combined data and time format.
    #
    # @param time [Time] The time to convert to ISO 8601 format.
    # @return [String] An ISO 8601 date in `YYYY-MM-DDTHH:MM:SSZ` format.
    def iso_format(time)
      time.strftime('%Y-%m-%dT%H:%M:%SZ')
    end
  end
end
