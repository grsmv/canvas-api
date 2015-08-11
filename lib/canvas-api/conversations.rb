module Canvas
  class API


    # Usage:
    #   ap c.create_conversation(
                                  # body: {
                                          # recipients: [3336],
                                          # subject:    'Subject',
                                          # body:       'Text ...'

                                  # })

    def create_conversation(body: {})
      post_collection __method__, body: body
    end

  end
end