module Canvas
  class API
    def enrollments(course_id:)
      endpoint = construct_endpoint __method__, ids: { course_id: course_id }
      HTTParty.get(endpoint).map &:to_struct
    end
  end
end