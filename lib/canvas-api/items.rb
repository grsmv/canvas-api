module Canvas
  class API
    def items(course_id:, module_id:)
      self.perform_request :get,
                           __method__,
                           ids: { course_id: course_id, module_id: module_id },
                           result_formatting: ->(collection) {
                             additional_attributes = { due_dates: [] }
                             collection.map { |i|
                               i.merge(additional_attributes).to_struct
                             }
                           }
    end
  end
end