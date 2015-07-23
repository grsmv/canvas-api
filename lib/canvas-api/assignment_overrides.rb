module Canvas
  class API
    def assignment_overrides(course_id:, assignment_id:)
      get_collection __method__, ids: { course_id: course_id, assignment_id: assignment_id }
    end

    # Usage:
    #   ap c.create_assignment_override(course_id: 40,
    #                                   assignment_id: 7,
    #                                   body: {
    #                                       assignment_override: {
    #                                           student_ids: [3336],
    #                                           course_section_id: 935,
    #                                           lock_at: Time.now.utc.iso8601,
    #                                           unlock_at: Time.now.utc.iso8601,
    #                                           due_at: nil
    #                                       }})
    def create_assignment_override(course_id:, assignment_id:, body: {})
      post_single __method__, ids: { course_id: course_id, assignment_id: assignment_id }, body: body
    end

    # Usage:
    #   ap c.update_assignment_override course_id: 40, assignment_id: 7, override_id: 24, body: {
    #                                                    assignment_override: {
    #                                                        student_ids: [3336, 3371],
    #                                                        course_section_id: 935,
    #                                                        lock_at: Time.now.utc.iso8601,
    #                                                        unlock_at: Time.now.utc.iso8601,
    #                                                        due_at: nil
    #                                                    }
    #                                                }
    def update_assignment_override(course_id:, assignment_id:, override_id:, body: {})
      put_single __method__, ids: { course_id: course_id, assignment_id: assignment_id, override_id: override_id }, body: body
    end

    def delete_assignment_override(course_id:, assignment_id:, override_id:)
      delete_single __method__, ids: { course_id: course_id, assignment_id: assignment_id, override_id: override_id }
    end
  end
end