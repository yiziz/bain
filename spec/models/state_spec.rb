require 'rails_helper'

RSpec.describe State, type: :model do
  describe '.id_to_state_code_hash' do
    before do
      FactoryGirl.create(:alabama_state)
      FactoryGirl.create(:texas_state)
    end

    it 'should return a hash with all the states' do
      states = State.all
      hash = State.id_to_state_code_hash

      expect(hash.keys.count).to eq(2)
      states.each do |state|
        expect(hash[state.id]).to eq(state.code)
      end
    end
  end

  describe '.state_code_to_id_hash' do
    before do
      FactoryGirl.create(:colorado_state)
      FactoryGirl.create(:texas_state)
    end

    it 'should return a hash with all the states' do
      states = State.all
      hash = State.state_code_to_id_hash

      expect(hash.keys.count).to eq(2)
      states.each do |state|
        expect(hash[state.code]).to eq(state.id)
      end
    end
  end
end
