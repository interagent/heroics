require 'minitest/autorun'
require 'heroics'

# A simple JSON schema for testing purposes.
SAMPLE_SCHEMA = {
  'definitions' => {
    'sample-resource' => {
      'description' => 'A sample resource to use in tests.',
      'id'          => 'schema/sample-resource',
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
          'example'     => '01234567-89ab-cdef-0123-456789abcdef',
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
          '$ref' => '#/definitions/sample-resource/definitions/date_field'},
        'string_field' => {
          '$ref' => '#/definitions/sample-resource/definitions/string_field'},
        'boolean_field' => {
          '$ref' => '#/definitions/sample-resource/definitions/boolean_field'},
        'uuid_field' => {
          '$ref' => '#/definitions/sample-resource/definitions/uuid_field'},
        'email_field' => {
          '$ref' => '#/definitions/sample-resource/definitions/email_field'},
      },

      'links' => [
        {'description' => 'Show all sample resources',
         'href'        => '/sample-resource',
         'method'      => 'GET',
         'rel'         => 'instances',
         'title'       => 'List'},

        {'description' => 'Show a sample resource',
         'href'        => '/sample-resource/(%23%2Fdefinitions%2Fsample-resource%2Fdefinitions%2Fuuid_field)}',
         'method'      => 'GET',
         'rel'         => 'self',
         'title'       => 'Info'},

        {'description' => 'Create sample resource',
         'href'        => '/sample-resource',
         'method'      => 'POST',
         'rel'         => 'create',
         'title'       => 'Create',
         'schema'      => {
           'properties' => {
             'date_field' => {
               '$ref' => '#/definitions/sample-resource/definitions/date_field'},
             'string_field' => {
               '$ref' => '#/definitions/sample-resource/definitions/string_field'},
             'boolean_field' => {
               '$ref' => '#/definitions/sample-resource/definitions/boolean_field'},
             'uuid_field' => {
               '$ref' => '#/definitions/sample-resource/definitions/uuid_field'},
             'email_field' => {
               '$ref' => '#/definitions/sample-resource/definitions/email_field'}}}},

        {'description' => 'Update sample resource',
         'href'        => '/sample-resource',
         'method'      => 'PATCH',
         'rel'         => 'update',
         'title'       => 'Update',
         'schema'      => {
           'properties' => {
             'date_field' => {
               '$ref' => '#/definitions/sample-resource/definitions/date_field'},
             'string_field' => {
               '$ref' => '#/definitions/sample-resource/definitions/string_field'},
             'boolean_field' => {
               '$ref' => '#/definitions/sample-resource/definitions/boolean_field'},
             'uuid_field' => {
               '$ref' => '#/definitions/sample-resource/definitions/uuid_field'},
             'email_field' => {
               '$ref' => '#/definitions/sample-resource/definitions/email_field'}}}},

        {'description' => 'Delete an existing sample resource.',
         'href'        => '/apps/{(%23%2Fdefinitions%2Fsample-resource%2Fdefinitions%2Fuuid_field)}',
         'method'      => 'DELETE',
         'rel'         => 'destroy',
         'title'       => 'Delete'}
      ]
    }
  }
}
