module Canvas
  class API
    def section(course_id:, section_id:)
      get_single __method__, ids: { course_id: course_id, section_id: section_id }
    end

    def update_section(course_id:, section_id:, body: {})
      put_single __method__, ids: { course_id: course_id, section_id: section_id }, body: body
    end
  end
end
