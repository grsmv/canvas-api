module Canvas
  class API
    def course(course_id:)
      get_single __method__, ids: { course_id: course_id }
    end
  end
end