module Canvas
  class API
    def quiz(course_id:, content_id:)
      endpoint = construct_endpoint __method__, ids: { course_id: course_id, content_id: content_id }
      HTTParty.get(endpoint).to_struct
    end
  end
end