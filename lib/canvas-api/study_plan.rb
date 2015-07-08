require 'parallel'

module Canvas
  class API
    def study_plan(course_id:)
      course_modules = modules(course_id: course_id)

      update_items_with_remote_data = -> (items) do
        Parallel.map(items, in_threads: items.size) do |item|
          if %w(Assignment Quiz Discussion).include? item.type
            item.payload = self.send(item.type.downcase, course_id: course_id, content_id: item.content_id)
          end
          item
        end
      end

      Parallel.map(course_modules, in_threads: course_modules.size) do |modul|
        modul.items = update_items_with_remote_data.call items(course_id: course_id, module_id: modul.id)
        modul
      end
    end
  end
end