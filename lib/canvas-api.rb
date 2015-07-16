require 'addressable/uri'
require 'httparty'
require 'vcr'
require 'base64'

require_relative './canvas-api/assignment'
require_relative './canvas-api/assignment_override'
require_relative './canvas-api/courses'
require_relative './canvas-api/course'
require_relative './canvas-api/discussion'
require_relative './canvas-api/enrollments'
require_relative './canvas-api/modules'
require_relative './canvas-api/items'
require_relative './canvas-api/sections'
require_relative './canvas-api/study_plan'
require_relative './canvas-api/quiz'
require_relative './canvas-api/quiz_assignment_override'
require_relative './canvas-api/version'

class Object
  def to_struct
    result = ::Hash[self.map{|k, v| [k.to_sym, v]}]
    ::Struct.new(*(k = result.keys)).new(*result.values_at(*k))
  end
end

module Canvas

  Endpoints = {
    courses:                  '/api/v1/courses',
    course:                   '/api/v1/courses/%{course_id}',
    enrollments:              '/api/v1/courses/%{course_id}/enrollments',
    modules:                  '/api/v1/courses/%{course_id}/modules',
    items:                    '/api/v1/courses/%{course_id}/modules/%{module_id}/items',
    sections:                 '/api/v1/courses/%{course_id}/sections',
    quiz:                     '/api/v1/courses/%{course_id}/quizzes/%{content_id}',
    quiz_assignment_override: '/api/v1/courses/%{course_id}/quizzes/assignment_overrides',
    assignment:               '/api/v1/courses/%{course_id}/assignments/%{content_id}',
    assignment_override:      '/api/v1/courses/%{course_id}/assignments/%{assignment_id}/overrides',
    discussion:               '/api/v1/courses/%{course_id}/discussion_topics/%{content_id}'
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
      uri.query_values = params.merge({access_token: options[:access_token]})
      resource = Canvas::Endpoints[method_name.to_sym] % ids
      "#{@options[:host]}#{resource}?#{uri.query}"
    end

    def get(method_name, ids: {}, params: {}, result_formatting: ->{})
      endpoint = construct_endpoint(method_name, ids: ids, params: params)
      puts 'GET ' + endpoint if @options[:verbose]

      fetching_data = lambda do
        content = HTTParty.get(endpoint)
        if content['error_report_id'].nil?
          result_formatting.call content
        end
      end

      @options[:cache] ?
        VCR.use_cassette(Base64.strict_encode64(endpoint), &fetching_data) :
        fetching_data.call
    end

    def get_single(method_name, ids: {}, params: {})
      get(method_name, ids: ids, params: params, result_formatting: ->(single){ single.to_struct })
    end

    def get_collection(method_name, ids: {}, params: {})
      get(method_name, ids: ids, params: params, result_formatting: ->(collection){ collection.map &:to_struct})
    end
  end
end