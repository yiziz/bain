class ProviderSerializer < ApplicationSerializer
  attributes :provider_name, :provider_street_address, :provider_city, :provider_zip_code
  attributes :hospital_referral_region_description, :total_discharges
  attributes :provider_state, :average_total_payments, :average_covered_charges, :average_medicare_payments

  def attributes(*args)
    hash = super(*args)
    hash.transform_keys! do |k|
      k.to_s.gsub('_', ' ').titleize
    end
  end

  def average_total_payments
    ActionController::Base.helpers.number_to_currency(self.object.average_total_payments_in_cents/100.0)
  end

  def average_covered_charges
    ActionController::Base.helpers.number_to_currency(self.object.average_covered_charges_in_cents/100.0)
  end

  def average_medicare_payments
    ActionController::Base.helpers.number_to_currency(self.object.average_medicare_payments_in_cents/100.0)
  end

  def provider_state
    state_id = self.object.state_id
    scope[:id_to_state_code_hash][state_id]
  end
end
