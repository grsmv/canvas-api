module Canvas
  class API
    def modules(course_id:)
      _, formatted = self.perform_request :get,
                                          __method__,
                                          ids: { course_id: course_id },
                                          result_formatting: ->(collection) {
                                            collection.map { |m| m.merge({ items: [] }).to_struct }
                                          }
      formatted
    end
  end
end