module Canvas
  class API

    # documentation: https://goo.gl/0HYdR5
    def enrollments(course_id:, params: {})
      get_collection __method__, ids: { course_id: course_id }, params: params
    end
  end
end