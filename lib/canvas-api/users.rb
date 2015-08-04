module Canvas
  class API
    def users(account_id:)
      get_collection __method__, ids: { account_id: account_id }
    end
  end
end