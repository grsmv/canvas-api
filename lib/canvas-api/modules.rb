module Canvas
  class API
    def modules(course_id:)
      self.perform_request :get,
                           __method__,
                           ids: { course_id: course_id },
                           result_formatting: ->(collection) {
                             collection.map { |m| m.merge({ items: [] }).to_struct }
                           }
    end
  end
end