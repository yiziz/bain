FactoryGirl.define do
  factory :provider do
    drg_definition                       "039 - EXTRACRANIAL PROCEDURES W/O CC/MCC"
    provider_name                        "SOUTHEAST ALABAMA MEDICAL CENTER"
    provider_street_address              "1108 ROSS CLARK CIRCLE"
    provider_city                        "DOTHAN"
    provider_zip_code                    "36301"
    hospital_referral_region_description "AL - Dothan"
    total_discharges                     91
    average_covered_charges_in_cents     3296307
    average_total_payments_in_cents      577724
    average_medicare_payments_in_cents   476373
    external_provider_id                 10001

    trait :zero_discharges do
      total_discharges 0
    end

    trait :five_discharges do
      total_discharges 5
    end

    trait :ten_discharges do
      total_discharges 10
    end

    trait :one_hundred_acc do
      average_covered_charges_in_cents 10000
    end

    trait :two_hundred_acc do
      average_covered_charges_in_cents 20000
    end

    trait :three_hundred_acc do
      average_covered_charges_in_cents 30000
    end

    trait :one_hundred_tp do
      average_total_payments_in_cents 10000
    end

    trait :two_hundred_tp do
      average_total_payments_in_cents 20000
    end

    trait :three_hundred_tp do
      average_total_payments_in_cents 30000
    end

    trait :one_hundred_mp do
      average_medicare_payments_in_cents 10000
    end

    trait :two_hundred_mp do
      average_medicare_payments_in_cents 20000
    end

    trait :three_hundred_mp do
      average_medicare_payments_in_cents 30000
    end
  end
end
