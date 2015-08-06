require 'addressable/uri'
require 'httparty'
require 'vcr'
require 'base64'

require_relative './canvas-api/assignment'
require_relative './canvas-api/assignment_overrides'
require_relative './canvas-api/courses'
require_relative './canvas-api/course'
require_relative './canvas-api/enrollments'
require_relative './canvas-api/enrollment'
require_relative './canvas-api/conclude_enrollment'
require_relative './canvas-api/modules'
require_relative './canvas-api/items'
require_relative './canvas-api/sections'
require_relative './canvas-api/section'
require_relative './canvas-api/section_enrollments'
require_relative './canvas-api/study_plan'
require_relative './canvas-api/quiz'
require_relative './canvas-api/submissions'
require_relative './canvas-api/conversations'
require_relative './canvas-api/admins'
require_relative './canvas-api/users'
require_relative './canvas-api/version'

class Object
  def to_struct
    result = ::Hash[self.map{|k, v| [k.to_sym, v]}]
    ::Struct.new(*(k = result.keys)).new(*result.values_at(*k))
  end
end

module Canvas

  Endpoints = {
    courses:                    '/api/v1/courses',
    course:                     '/api/v1/courses/%{course_id}',
    enrollments:                '/api/v1/courses/%{course_id}/enrollments',
    enrollment:                 '/api/v1/accounts/%{account_id}/enrollments/%{enrollment_id}',
    conclude_enrollment:        '/api/v1/courses/%{course_id}/enrollments/%{enrollment_id}',
    modules:                    '/api/v1/courses/%{course_id}/modules',
    items:                      '/api/v1/courses/%{course_id}/modules/%{module_id}/items',
    sections:                   '/api/v1/courses/%{course_id}/sections',
    section:                    '/api/v1/courses/%{course_id}/sections/%{section_id}',
    section_enrollments:        '/api/v1/sections/%{section_id}/enrollments',
    quiz:                       '/api/v1/courses/%{course_id}/quizzes/%{content_id}',
    assignment:                 '/api/v1/courses/%{course_id}/assignments/%{content_id}',
    assignment_overrides:       '/api/v1/courses/%{course_id}/assignments/%{assignment_id}/overrides',
    create_assignment_override: '/api/v1/courses/%{course_id}/assignments/%{assignment_id}/overrides',
    update_assignment_override: '/api/v1/courses/%{course_id}/assignments/%{assignment_id}/overrides/%{override_id}',
    delete_assignment_override: '/api/v1/courses/%{course_id}/assignments/%{assignment_id}/overrides/%{override_id}',
    submissions:                '/api/v1/sections/%{section_id}/assignments/%{assignment_id}/submissions',
    create_conversation:        '/api/v1/conversations',
    admins:                     '/api/v1/accounts/%{account_id}/admins',
    users:                      '/api/v1/accounts/%{account_id}/users'
  }

  # Main class. All useful work we are doing here. Should be initialised using
  # credentials, received from Canvas.
  #
  # == Usage:
  #   api = Canvas::API.new(host:'https://canvas-host.com', access_token: 'secret')
  #   # getting all courses from host:
  #   api.courses
  #
  class API

    attr_accessor :options

    # Initializes new API object using given credentials and additional options
    #
    # == Parameters:
    # host::
    #   A String with given URI of Canvas Host
    # access_token::
    #   A String with access token, generated in Canvas administrative panel
    # cache::
    #   Boolean flag, allowing to perform hard requests caching through VCR if
    #   equals `true`. `false` by default
    #
    # == Returns:
    #   An API object, configured for further requests
    #
    def initialize(host:, access_token:, cache: false, verbose: false)
      @options = { host: host, access_token: access_token, cache: cache, verbose: verbose}

      if @options[:cache]
        VCR.configure do |config|
          config.allow_http_connections_when_no_cassette = true
          config.cassette_library_dir = '/tmp/canvas-api'
          config.hook_into :webmock
        end
      end
    end


    # Local wrapper for HTTParty gem. Hides response handling and formatting under the hood
    #
    # == Parameters:
    # http_verb::
    #   Symbol with one of the standard HTTP verb
    # method_name::
    #   Symbol with API resource name (by which search in Endpoint will be performed)
    # ids::
    #   Hash with collection of URI template variables (with be processed during endpoint URI construction)
    # params::
    #   Hash with additional request params. Will be processed in 'k=v&a=c' form during endpoint creation.
    # body::
    #   Hash with possible request body (make sense in create-update requests)
    # result_formatting::
    #   Proc with response formatting instructions
    #
    # == Returns:
    #   raw Hash
    #
    def perform_request(http_verb, method_name, ids: {}, params: {}, body: {}, result_formatting: ->{})

      endpoint = construct_endpoint(method_name, ids: ids, params: params)
      puts "#{http_verb.upcase}" + endpoint if @options[:verbose]

      fetching_data = lambda do
        content = HTTParty.send(http_verb.to_sym, endpoint, query: body)
        begin
          result_formatting.call content
        rescue
          nil
        end
      end

      if @options[:cache]
        VCR.use_cassette(Base64.strict_encode64(endpoint), &fetching_data)
      else
        fetching_data.call
      end
    end


    # Creating corresponding helpers for performing requests during class initialisation
    %i(get post put delete).each do |http_verb|
      define_method("#{http_verb}_single") do |method_name, ids: {}, params: {}, body: {}|
        self.perform_request(http_verb, method_name, ids: ids, params: params, body: body, result_formatting: ->(s) { s.to_struct })
      end

      define_method("#{http_verb}_collection") do |method_name, ids: {}, params: {}, body: {}|
        params[:per_page] = 10_000 if http_verb == :get and params[:per_page].nil?
        self.perform_request(http_verb, method_name, ids: ids, params: params, body: body, result_formatting: ->(cs){ cs.map &:to_struct })
      end
    end


    # Check whether module item is an assignment or not
    def self.assignment?(item)
      %w(Assignment Quiz).include? item.type
    end

    private

    # Compiling resource's endpoint, using endpoint template, Hash of resourde IDs
    # and associated list of non-mandatory params
    #
    # == Parameters:
    # method_name::
    #   a Symbol with callee method name
    # ids::
    #   associated list of resource IDs. Will be used during endpoint template
    #   compilation
    # params::
    #   associated list of non-mandatory parameters (e.c.resource type specification, etc.)
    #
    # == Returns:
    #   String with compiled resource URI (`access_token` included)
    #
    def construct_endpoint(method_name, ids: {}, params: {})
      uri = Addressable::URI.new
      uri.query_values = params.merge(access_token: options[:access_token])
      resource = Canvas::Endpoints[method_name.to_sym] % ids
      "#{@options[:host]}#{resource}?#{uri.query}"
    end
  end
end