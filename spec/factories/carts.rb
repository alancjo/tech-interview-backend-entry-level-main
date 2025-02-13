FactoryBot.define do
  factory :cart do
    status { :active }
    total_price { 0 }
    last_interaction_at { Time.current }

    trait :abandoned do
      status { :abandoned }
      last_interaction_at { 4.hours.ago }
    end

    trait :old_abandoned do
      status { :abandoned }
      last_interaction_at { 8.days.ago }
    end
  end
end