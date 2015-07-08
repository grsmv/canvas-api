require 'httparty'

require 'canvas-api/version'
require 'canvas-api/courses'
require 'canvas-api/course'
require 'canvas-api/enrollments'
require 'canvas-api/modules'
require 'canvas-api/items'
require 'canvas-api/sections'
require 'canvas-api/study_plan'
require 'canvas-api/quiz'
require 'canvas-api/assignment'
require 'canvas-api/discussion'

class Object
  def to_struct
    result = ::Hash[self.map{|k, v| [k.to_sym, v]}]
    ::Struct.new(*(k = result.keys)).new(*result.values_at(*k))
  end
end

module Canvas

  Endpoints = {
    courses:     '/api/v1/courses',
    course:      '/api/v1/courses/%{course_id}',
    enrollments: '/api/v1/courses/%{course_id}/enrollments',
    modules:     '/api/v1/courses/%{course_id}/modules',
    items:       '/api/v1/courses/%{course_id}/modules/%{module_id}/items',
    sections:    '/api/v1/courses/%{course_id}/sections',
    quiz:        '/api/v1/courses/%{course_id}/quizzes/%{content_id}',
    assignment:  '/api/v1/courses/%{course_id}/assignments/%{content_id}',
    discussion:  '/api/v1/courses/%{course_id}/discussion_topics/%{content_id}'
  }

  class API

    attr_accessor :options

    def initialize(host:, access_token:, verbose: false)
      @options = { host: host, access_token: access_token, verbose: verbose }
    end

    private

    def construct_endpoint(method_name, ids: {})
      resource = Canvas::Endpoints[method_name.to_sym] % ids
      "#{@options[:host]}#{resource}?access_token=#{options[:access_token]}"
    end
  end
end