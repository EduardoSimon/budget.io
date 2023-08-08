FactoryBot.define do
  factory :movement do
    payer { 'Jhon Doe' }
    description { 'test movement' }
    account

    trait(:with_amount) do
      amount { Money.new(123_00, 'EUR') }
    end
  end
end
