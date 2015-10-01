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

      # Updating IDs for discussions and quizzes 'cause Canvas has 2 IDs for
      # each corresponding item - all depends on a way which we use to retrieve them.
      # And we should use one, which came from `assignments` endpoint.
      assignments = self.assignments(course_id: course_id)
      update_ids_for_discussions_and_quizzes = -> (items) do
        items.map do |item|
          if %w(Quiz Discussion).include? item.type
            filtrated = assignments.select do |a|
              item.content_id == case item.type
                                   when 'Discussion'
                                     a.discussion_topic['id'] if a.respond_to? :discussion_topic
                                   when 'Quiz'
                                     a.quiz_id if a.respond_to? :quiz_id
                                 end
            end
            if filtrated.size.zero? || filtrated[0].nil?
              item = nil
            else
              item.id = filtrated.first.id
            end
          end
          item
        end
      end

      update_module = lambda do |m|
        m.tap do |mod|
          unless mod.items_count.zero?
            items = update_ids_for_discussions_and_quizzes.call(self.items course_id: course_id, module_id: mod.id)
            #filter out stuff that doesn't have a content_id, this means it's not an assignment
            items = items.select{|item| (item.respond_to?('content_id'))}
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
          if self.class.assignment?(item)
            assignment_details = self.assignment(
                course_id: course_id,
                content_id: item.type == 'Assignment' ? item.content_id : item.id)

            item.due_dates = [{student_id: 0, due_at: assignment_details.due_at}]

            overrides = self.assignment_overrides(
                course_id: course_id,
                assignment_id: item.type == 'Assignment' ? item.content_id : item.id)

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
        if due_date.members.include? :student_ids
          due_date.student_ids.map do |student_id|
            {
                student_id: student_id,
                due_at: due_date[:due_at],
                override_id: due_date[:id]
            }
          end
        end
      end.flatten
    end
  end
end
