FactoryBot.define do
  factory :institution do
    name { "Test institution" }
    thumbnail_url { "wadus" }
    sequence(:institution_id) do |n|
      "external_institution_id_#{n}"
    end
  end
end
