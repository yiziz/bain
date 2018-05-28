require 'rails_helper'

RSpec.describe V1::ProvidersController, type: :controller do
  describe 'GET index' do
    before do
      alabama_state = FactoryGirl.create(:alabama_state)
      colorado_state = FactoryGirl.create(:colorado_state)
      FactoryGirl.create(:provider, :zero_discharges, :one_hundred_mp, :one_hundred_tp, :one_hundred_acc, state: alabama_state)
      FactoryGirl.create(:provider, :five_discharges, :two_hundred_mp, :two_hundred_tp, :two_hundred_acc, state: alabama_state)
      FactoryGirl.create(:provider, :ten_discharges, :three_hundred_mp, :three_hundred_tp, :three_hundred_acc, state: alabama_state)
    end

    context 'with bad params' do
      it 'should respond with 400 and errors' do
        params = {
          state: 'XX',
        }
        get :index, params: params

        query = Queries::ProviderQuery.new
        query.filter(Provider.all, params)
        expect(response.status).to eq(400)
        expect(response.body).to eq(query.errors.to_json)
      end
    end

    context 'with good params' do
      it 'should respond with 200 and providers data' do
        get :index

        expect(response.status).to eq(200)
        expect(response.body).to eq(
          ActiveModelSerializers::SerializableResource.new(Provider.all, each_serializer: ProviderSerializer).to_json
        )
      end
    end
  end
end
