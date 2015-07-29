module Canvas
  class API

    def create_conversation(body: {})
      post_single __method__, body: body
    end

  end
end