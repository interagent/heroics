# frozen_string_literal: true
require 'base64'
require 'erubis'
require 'excon'
require 'multi_json'
require 'uri'
require 'zlib'

# Heroics is an HTTP client for an API described by a JSON schema.
module Heroics
  extend self

  def default_configuration(&block)
    block ||= lambda { |c| }
    Heroics::Configuration.defaults.tap(&block)
  end
end

require 'heroics/version'
require 'heroics/errors'
require 'heroics/configuration'
require 'heroics/naming'
require 'heroics/link'
require 'heroics/resource'
require 'heroics/client'
require 'heroics/schema'
require 'heroics/command'
require 'heroics/cli'
require 'heroics/client_generator'
