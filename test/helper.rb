require 'minitest/autorun'
require 'minitest/pride'
require 'time'

require 'heroics'

module ExconHelper
  def setup
    super
    Excon.stubs.clear
    Excon.defaults[:mock] = true
  end

  def teardown
    # FIXME This is a bit ugly, but Excon doesn't provide a builtin way to
    # ensure that a request was invoked, so we have to do it ourselves.
    # Without this, and the Excon.stubs.pop calls in the tests that use this
    # helper, tests will pass if request logic is completely removed from
    # application code. -jkakar
    assert(Excon.stubs.empty?, 'Expected HTTP requests were not made.')
    super
  end
end

# A simple JSON schema for testing purposes.
SAMPLE_SCHEMA = {
  'definitions' => {
    'resource' => {
      'description' => 'A sample resource to use in tests.',
      'id'          => 'schema/resource',
      '$schema'     => 'http://json-schema.org/draft-04/hyper-schema',
      'title'       => 'Sample resource title',
      'type'        => ['object'],

      'definitions' => {
        'date_field' => {
          'description' => 'A sample date field',
          'example'     => '2013-10-19 22:10:29Z',
          'format'      => 'date-time',
          'readOnly'    => true,
          'type'        => ['string']
        },

        'string_field' => {
          'description' => 'A sample string field',
          'example'     => 'Sample text.',
          'readOnly'    => true,
          'type'        => ['string']
        },

        'boolean_field' => {
          'description' => 'A sample boolean field',
          'example'     => true,
          'type'        => ['boolean']
        },

        'uuid_field' => {
          'description' => 'A sample UUID field',
          'example'     => '44724831-bf66-4bc2-865f-e2c4c2b14c78',
          'format'      => 'uuid',
          'readOnly'    => true,
          'type'        => ['string']
        },

        'email_field' => {
          'description' => 'A sample email address field',
          'example'     => 'username@example.com',
          'format'      => 'email',
          'readOnly'    => true,
          'type'        => ['string']
        }
      },

      'properties' => {
        'date_field' => {
          '$ref' => '#/definitions/resource/definitions/date_field'},
        'string_field' => {
          '$ref' => '#/definitions/resource/definitions/string_field'},
        'boolean_field' => {
          '$ref' => '#/definitions/resource/definitions/boolean_field'},
        'uuid_field' => {
          '$ref' => '#/definitions/resource/definitions/uuid_field'},
        'email_field' => {
          '$ref' => '#/definitions/resource/definitions/email_field'},
      },

      'links' => [
        {'description' => 'Show all sample resources',
         'href'        => '/resource',
         'method'      => 'GET',
         'rel'         => 'instances',
         'title'       => 'List'},

        {'description' => 'Show a sample resource',
         'href'        => '/resource/{(%23%2Fdefinitions%2Fresource%2Fdefinitions%2Fuuid_field)}',
         'method'      => 'GET',
         'rel'         => 'self',
         'title'       => 'Info'},

        {'description' => 'Create a sample resource',
         'href'        => '/resource',
         'method'      => 'POST',
         'rel'         => 'create',
         'title'       => 'Create',
         'schema'      => {
           'properties' => {
             'date_field' => {
               '$ref' => '#/definitions/resource/definitions/date_field'},
             'string_field' => {
               '$ref' => '#/definitions/resource/definitions/string_field'},
             'boolean_field' => {
               '$ref' => '#/definitions/resource/definitions/boolean_field'},
             'uuid_field' => {
               '$ref' => '#/definitions/resource/definitions/uuid_field'},
             'email_field' => {
               '$ref' => '#/definitions/resource/definitions/email_field'}}}},

        {'description' => 'Update a sample resource',
         'href'        => '/resource/{(%23%2Fdefinitions%2Fresource%2Fdefinitions%2Fuuid_field)}',
         'method'      => 'PATCH',
         'rel'         => 'update',
         'title'       => 'Update',
         'schema'      => {
           'properties' => {
             'date_field' => {
               '$ref' => '#/definitions/resource/definitions/date_field'},
             'string_field' => {
               '$ref' => '#/definitions/resource/definitions/string_field'},
             'boolean_field' => {
               '$ref' => '#/definitions/resource/definitions/boolean_field'},
             'uuid_field' => {
               '$ref' => '#/definitions/resource/definitions/uuid_field'},
             'email_field' => {
               '$ref' => '#/definitions/resource/definitions/email_field'}}}},

        {'description' => 'Delete an existing sample resource at specific time',
         'href'        => '/resource/{(%23%2Fdefinitions%2Fresource%2Fdefinitions%2Fdate_field)}',
         'method'      => 'DELETE',
         'rel'         => 'destroy',
         'title'       => 'Delete'}
      ]
    }
  }
}
