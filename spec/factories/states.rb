FactoryGirl.define do
  factory :state do
    factory :alabama_state do
      code 'AL'
      name 'Alabama'
    end

    factory :colorado_state do
      code 'CO'
      name 'Colorado'
    end

    factory :texas_state do
      code 'TX'
      name 'Texas'
    end
  end
end
