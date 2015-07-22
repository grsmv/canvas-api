module Canvas
  class API
    def assignment_override(course_id:, assignment_id:)
      get_collection __method__, ids: { course_id: course_id, assignment_id: assignment_id }
    end

    # Usage:
    #   ap c.create_assignment_override(course_id: 40,
    #                                   assignment_id: 7,
    #                                   body: {
    #                                       assignment_override: {
    #                                           title: 'Maryna Kupriyanchuk',
    #                                           student_ids: [3336],
    #                                           course_section_id: 935,
    #                                           lock_at: Time.now.utc.iso8601,
    #                                           unlock_at: Time.now.utc.iso8601,
    #                                           due_at: nil
    #                                       }})
    def create_assignment_override(course_id:, assignment_id:, body: {})
      post_single __method__, ids: {course_id: course_id, assignment_id: assignment_id }, body: body
    end
  end
end