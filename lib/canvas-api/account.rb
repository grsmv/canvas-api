module Canvas
  class API
    def account(account_id:)
      get_single __method__, ids: { account_id: account_id }
    end
  end
end