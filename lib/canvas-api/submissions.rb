module Canvas
  class API

    def submissions(section_id:, assignment_id:)
      get_collection __method__, ids: { section_id: course_id, assignment_id: assignment_id }
    end

  end
end