FactoryBot.define do
  factory :account do
    name { "Test account" }
    iban  { "ES9121000418450200051332" }
    sequence(:external_account_id) do |n|
       "external_account_#{n}"
    end
    balance { 2000.20 }
    budget
    institution
  end
end
