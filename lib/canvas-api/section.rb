module Canvas
  class API
    def section(course_id:, section_id:)
      get_single __method__, ids: { course_id: course_id, section_id: section_id }
    end
  end
end