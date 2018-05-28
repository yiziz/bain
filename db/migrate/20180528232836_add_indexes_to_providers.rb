class AddIndexesToProviders < ActiveRecord::Migration[5.2]
  def change
    add_index     :providers, :total_discharges
    add_index     :providers, :average_covered_charges_in_cents
    add_index     :providers, :average_total_payments_in_cents
    add_index     :providers, :average_medicare_payments_in_cents
  end
end
