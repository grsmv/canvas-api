module Canvas
  class API

    # documentation: https://goo.gl/0HYdR5
    def enrollments(course_id:, params: {})
      endpoint = construct_endpoint __method__, ids: { course_id: course_id }, params: params
      HTTParty.get(endpoint).map &:to_struct
    end
  end
end