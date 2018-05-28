class State < ActiveRecord::Base
  has_many :providers

  def self.id_to_state_code_hash
    Rails.cache.fetch("id_to_state_code_hash") do
      State.all.map { |state| [state.id, state.code] }.to_h
    end
  end

  def self.state_code_to_id_hash
    Rails.cache.fetch("state_code_to_id_hash") do
      State.all.map { |state| [state.code, state.id] }.to_h
    end
  end
end
