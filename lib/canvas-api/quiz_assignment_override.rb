module Canvas
  class API

    # Getting all assignments overrides for all quizzes in course.
    #
    # == Parameters::
    # course_id::
    #   Integer with course ID
    #
    # == Returns:
    #   Collection of quiz assignment overrides objects
    #
    def quiz_assignment_override(course_id:)
      get_single __method__, ids: { course_id: course_id }
    end
  end
end