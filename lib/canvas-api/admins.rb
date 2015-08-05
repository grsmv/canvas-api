module Canvas
  class API
    def admins(account_id:)
      get_collection __method__, ids: { account_id: account_id }
    end
  end
end