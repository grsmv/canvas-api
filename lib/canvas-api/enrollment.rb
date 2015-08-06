module Canvas
  class API
    def enrollment(account_id:, enrollment_id:)
      get_single __method__, ids: { account_id: account_id, enrollment_id: enrollment_id }
    end
  end
end