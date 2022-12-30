json.extract! account, :id, :name, :iban, :created_at, :updated_at
json.url account_url(account, format: :json)
