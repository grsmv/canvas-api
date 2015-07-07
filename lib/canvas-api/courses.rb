module Canvas
  class API
    def courses
      endpoint = construct_endpoint __method__
      HTTParty.get(endpoint).map &:to_struct
    end
  end
end