require 'parallel'

module Canvas
  class API
    def study_plan(course_id:)
      course_modules = modules(course_id: course_id)
      Parallel.map(course_modules, in_threads: course_modules.size) do |modul|
        modul.tap { |m| m.items = items(course_id: course_id, module_id: modul.id) }
      end
    end
  end
end