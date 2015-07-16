module Canvas
  class API
    def assignment_override(course_id:, assignment_id:)
      get_collection __method__, ids: { course_id: course_id, assignment_id: assignment_id }
    end
  end
end