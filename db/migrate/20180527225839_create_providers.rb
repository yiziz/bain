class CreateProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :providers do |t|
      t.string     :drg_definition
      t.string     :provider_name
      t.string     :provider_street_address
      t.string     :provider_city
      t.string     :provider_zip_code
      t.string     :hospital_referral_region_description

      t.integer    :total_discharges
      t.integer    :average_covered_charges_in_cents
      t.integer    :average_total_payments_in_cents
      t.integer    :average_medicare_payments_in_cents

      t.integer    :external_provider_id
      t.belongs_to :state
    end
  end
end
