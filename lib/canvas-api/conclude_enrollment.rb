module Canvas
  class API
    def conclude_enrollment(course_id:, enrollment_id:)
      delete_single __method__, ids: {course_id: course_id, enrollment_id: enrollment_id}, params: {task: 'conclude'}
    end
  end
end