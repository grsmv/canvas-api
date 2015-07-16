require 'parallel'

module Canvas
  class API

    # List of all modules with all items in modules for given course. NOTE: __parallel__ gem usage
    # caused by pursuit for performance improvements. This gem don't plays nicely with __VCR__ gem,
    # so we need to switch off parallel computations when caching is enabled in `@options[:cache]`.
    #
    # == Parameters:
    # course_id::
    #   an Integer with certain course ID
    #
    # == Returns:
    #   Collection of modules with items
    #
    def study_plan(course_id:)
      course_modules = modules(course_id: course_id)
      update_module = lambda do |m|
        m.tap do |mod|
          unless mod.items_count.zero?
            items = self.items(course_id: course_id, module_id: mod.id)
            mod.items = fill_due_dates course_id, items
          end
        end
      end

      @options[:cache] ?
        course_modules.map(&update_module) :
        Parallel.map(course_modules, in_threads: course_modules.size, &update_module)
    end
    
    private

    def fill_due_dates(course_id, items)
      update_item = lambda do |item|
        item.tap do |item|
          if %w(Assignment Quiz).include? item.type
            assignment_details = self.send(item.type.downcase,
                                           course_id: course_id,
                                           content_id: item.content_id)
            item.due_dates = [{student_id: 0, due_at: assignment_details.due_at}]

            overrides = self.assignment_override(course_id: course_id,
                                                 assignment_id: item.content_id)
            unless overrides.nil?
              item.due_dates += expand_due_dates_for_students(overrides)
            end
          end
        end
      end

      @options[:cache] ?
        items.map(&update_item) :
        Parallel.map(items, in_threads: items.size, &update_item)
    end

    def expand_due_dates_for_students(due_dates)
      due_dates.map do |due_date|
        due_date[:student_ids].map do |student_id|
          {
            student_id: student_id,
            due_at: due_date[:due_at]
          }
        end
      end.flatten
    end
  end
end