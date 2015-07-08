module Canvas
  class API
    def modules(course_id:)
      endpoint = construct_endpoint __method__, ids: { course_id: course_id }
      HTTParty.get(endpoint).map do |modul|
        modul.merge({items: []}).to_struct
      end
    end
  end
end