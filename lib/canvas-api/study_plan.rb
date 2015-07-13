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

      update_items_with_remote_data = -> (items) do
        update_item = lambda do |item|
          if %w(Assignment Quiz Discussion).include? item.type
            item.payload = self.send(item.type.downcase, course_id: course_id, content_id: item.content_id)
          end
          item
        end

        @options[:cache] ?
          items.map(&update_item) :
          Parallel.map(items, in_threads: items.size, &update_item)
      end

      update_module = lambda do |modul|
        unless modul.items_count.zero?
          modul.items = update_items_with_remote_data.call items(course_id: course_id, module_id: modul.id)
        end
        modul
      end

      @options[:cache] ?
        course_modules.map(&update_module) :
        Parallel.map(course_modules, in_threads: course_modules.size, &update_module)
    end
  end
end