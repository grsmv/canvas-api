module Canvas
  class API
    def items(course_id:, module_id:)
      endpoint = construct_endpoint __method__, ids: { course_id: course_id, module_id: module_id }
      HTTParty.get(endpoint).map &:to_struct
    end
  end
end