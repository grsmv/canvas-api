module Canvas
  class API
    def assignment_override(course_id:, assignment_id:)
      get_collection __method__, ids: { course_id: course_id, assignment_id: assignment_id }
    end

=begin
    assignment_override = {
      student_ids: [],
      title: "Some Name", # student's name
      course_section_id: Int, # course section ID (if any)
      due_at: Date
    }
=end
    def create_assignment_override(course_id:, assignment_id:)

    end
  end
end