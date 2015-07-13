module Canvas
  class API
    def modules(course_id:)
      get __method__,
          ids: { course_id: course_id },
          result_formatting: ->(collection) {
            collection.map { |m| m.merge({ items: [] }).to_struct }
          }
    end
  end
end