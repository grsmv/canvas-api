module Canvas
  class API
    def course(course_id:)
      endpoint = construct_endpoint __method__, ids: { course_id: course_id }
      HTTParty.get(endpoint).to_struct
    end
  end
end