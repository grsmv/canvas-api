module Canvas
  class API
    def sections(course_id:)
      get_collection __method__, ids: { course_id: course_id }
    end
  end
end