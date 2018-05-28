class State < ActiveRecord::Base

  def self.id_to_state_code_hash
    Rails.cache.fetch("id_to_state_code_hash") do
      State.all.map { |state| [state.id, state.code] }.to_h
    end
  end
end
