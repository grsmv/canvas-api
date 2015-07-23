module Canvas
  class API
    def section_enrollments(section_id:, params: {})
      get_collection __method__, ids: { section_id: section_id }, params: params
    end
  end
end