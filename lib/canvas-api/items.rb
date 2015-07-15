module Canvas
  class API
    def items(course_id:, module_id:)
      get __method__,
          ids: { course_id: course_id, module_id: module_id },
          result_formatting: ->(collection) {
            collection.map { |i| i.merge({ payload: {}, due_dates: {} }).to_struct }
          }
    end
  end
end