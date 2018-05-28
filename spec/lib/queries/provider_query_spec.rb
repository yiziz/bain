require 'rails_helper'

describe Queries::ProviderQuery do
  describe 'Querying providers' do
    let(:query)         { Queries::ProviderQuery.new }
    let(:default_scope) { Provider.all }

    before do
      alabama_state = FactoryGirl.create(:alabama_state)
      colorado_state = FactoryGirl.create(:colorado_state)
      FactoryGirl.create(:provider, :zero_discharges, :one_hundred_mp, :one_hundred_tp, :one_hundred_acc, state: alabama_state)
      FactoryGirl.create(:provider, :five_discharges, :two_hundred_mp, :two_hundred_tp, :two_hundred_acc, state: alabama_state)
      FactoryGirl.create(:provider, :ten_discharges, :three_hundred_mp, :three_hundred_tp, :three_hundred_acc, state: alabama_state)
    end

    context 'with no params' do
      it 'should return all providers' do
        params = {}
        providers = query.filter(default_scope, params)
        expect(query.errors.size).to eq(0)
        expect(Provider.all.size).to eq(providers.size)
      end
    end

    context 'with params' do
      context 'with an undocumented param' do
        params = {
          undocumented: 1,
        }

        it 'should return all providers' do
          providers = query.filter(default_scope, params)
          expect(query.errors.size).to eq(0)
          expect(Provider.all.size).to eq(providers.size)
        end
      end

      context 'with min_average_covered_charges' do
        params = {
          min_average_covered_charges: '300',
        }

        it 'should return providers with average_covered_charges >= 300' do
          providers = query.filter(default_scope, params)
          expect(query.errors.size).to eq(0)
          expect(providers.size).to eq(1)
          expect(providers.first.average_covered_charges_in_cents).to be >= params[:min_average_covered_charges].to_i * 100
        end
      end

      context 'with max_average_covered_charges' do
        params = {
          max_average_covered_charges: '100',
        }

        it 'should return providers with average_covered_charges <= 100' do
          providers = query.filter(default_scope, params)
          expect(query.errors.size).to eq(0)
          expect(providers.size).to eq(1)
          expect(providers.first.average_covered_charges_in_cents).to be <= params[:max_average_covered_charges].to_i * 100
        end
      end

      context 'with min_average_covered_charges and max_average_covered_charges' do
        params = {
          min_average_covered_charges: '101',
          max_average_covered_charges: '299',
        }

        it 'should return providers with average_covered_charges >= 101 and <= 299' do
          providers = query.filter(default_scope, params)
          expect(query.errors.size).to eq(0)
          expect(providers.size).to eq(1)
          expect(providers.first.average_covered_charges_in_cents).to be_between(
            params[:min_average_covered_charges].to_i * 100,
            params[:max_average_covered_charges].to_i * 100,
          ).inclusive
        end
      end

      context 'with min_average_medicare_payments' do
        params = {
          min_average_medicare_payments: '300',
        }

        it 'should return providers with average_medicare_payments >= 300' do
          providers = query.filter(default_scope, params)
          expect(query.errors.size).to eq(0)
          expect(providers.size).to eq(1)
          expect(providers.first.average_medicare_payments_in_cents).to be >= params[:min_average_medicare_payments].to_i * 100
        end
      end

      context 'with max_average_medicare_payments' do
        params = {
          max_average_medicare_payments: '100',
        }

        it 'should return providers with average_medicare_payments <= 100' do
          providers = query.filter(default_scope, params)
          expect(query.errors.size).to eq(0)
          expect(providers.size).to eq(1)
          expect(providers.first.average_medicare_payments_in_cents).to be <= params[:max_average_medicare_payments].to_i * 100
        end
      end

      context 'with min_average_medicare_payments and max_average_medicare_payments' do
        params = {
          min_average_medicare_payments: '101',
          max_average_medicare_payments: '299',
        }

        it 'should return providers with average_medicare_payments >= 101 and <= 299' do
          providers = query.filter(default_scope, params)
          expect(query.errors.size).to eq(0)
          expect(providers.size).to eq(1)
          expect(providers.first.average_medicare_payments_in_cents).to be_between(
            params[:min_average_medicare_payments].to_i * 100,
            params[:max_average_medicare_payments].to_i * 100,
          ).inclusive
        end
      end

      context 'with min_discharges' do
        params = {
          min_discharges: '10',
        }

        it 'should return providers with average_covered_charges >= 10' do
          providers = query.filter(default_scope, params)
          expect(query.errors.size).to eq(0)
          expect(providers.size).to eq(1)
          expect(providers.first.total_discharges).to be >= params[:min_discharges].to_i
        end
      end

      context 'with max_discharges' do
        params = {
          max_discharges: '0',
        }

        it 'should return providers with total_discharges <= 0' do
          providers = query.filter(default_scope, params)
          expect(query.errors.size).to eq(0)
          expect(providers.size).to eq(1)
          expect(providers.first.total_discharges).to be <= params[:max_charges].to_i
        end
      end

      context 'with min_discharges and max_discharges' do
        params = {
          min_discharges: '1',
          max_discharges: '9',
        }

        it 'should return providers with total_discharges >= 1 and <= 9' do
          providers = query.filter(default_scope, params)
          expect(query.errors.size).to eq(0)
          expect(providers.size).to eq(1)
          expect(providers.first.total_discharges).to be_between(
            params[:min_discharges].to_i,
            params[:max_discharges].to_i,
          ).inclusive
        end
      end

      context 'with a min_discharges greater than max_discharges' do
        params = {
          min_discharges: '9',
          max_discharges: '1',
        }

        it 'should return no providers' do
          providers = query.filter(default_scope, params)
          expect(query.errors.size).to eq(0)
          expect(providers.size).to eq(0)
        end
      end

      context 'with bad numbers' do
        params = {
          min_average_covered_charges: 'a',
          max_average_covered_charges: '1.9.0',
          min_average_medicare_payments: '1b01',
          max_average_medicare_payments: 'ccc',
          min_discharges: 'c9n',
          max_discharges: '1_00',
        }

        it 'should have errors' do
          providers = query.filter(default_scope, params)
          combined_error_string = query.errors.join
          expect(query.errors.size).to eq(6)
          expect(combined_error_string).to include('min_average_covered_charges')
          expect(combined_error_string).to include('max_average_covered_charges')
          expect(combined_error_string).to include('min_average_medicare_payments')
          expect(combined_error_string).to include('max_average_medicare_payments')
          expect(combined_error_string).to include('min_discharges')
          expect(combined_error_string).to include('max_discharges')
        end
      end

      context 'with a good state code' do
        params = {
          state: 'AL',
        }

        it 'should return providers within the specified state' do
          providers = query.filter(default_scope, params)
          expect(query.errors.size).to eq(0)
          expect(providers.size).to eq(3)

          providers.each do |p|
            expect(State.id_to_state_code_hash[p.state_id]).to eq(params[:state])
          end
        end
      end

      context 'with a bad state code' do
        params = {
          state: 'XX',
        }

        it 'should have errors' do
          providers = query.filter(default_scope, params)
          expect(query.errors.size).to eq(1)
          expect(query.errors.first).to include('state')
        end
      end

      context 'with max_discharges, min_discharges, max_average_covered_charges, min_average_covered_charges, max_average_medicare_payments, min_average_medicare_payments, and state' do
        params = {
          min_average_covered_charges: '101',
          max_average_covered_charges: '299',
          min_average_medicare_payments: '101',
          max_average_medicare_payments: '299',
          min_discharges: '1',
          max_discharges: '9',
          state: 'AL',
        }

        it 'should return providers that match all param values' do
          providers = query.filter(default_scope, params)
          expect(query.errors.size).to eq(0)
          expect(providers.size).to eq(1)

          provider = providers.first
          expect(provider.total_discharges).to be_between(
            params[:min_discharges].to_i,
            params[:max_discharges].to_i,
          ).inclusive
          expect(provider.average_covered_charges_in_cents).to be_between(
            params[:min_average_covered_charges].to_i * 100,
            params[:max_average_covered_charges].to_i * 100,
          ).inclusive
          expect(provider.average_medicare_payments_in_cents).to be_between(
            params[:min_average_medicare_payments].to_i * 100,
            params[:max_average_medicare_payments].to_i * 100,
          ).inclusive
          expect(State.id_to_state_code_hash[provider.state_id]).to eq(params[:state])
        end
      end

      context 'with valid values that get no results' do
        params = {
          min_average_covered_charges: '301',
          max_average_covered_charges: '499',
          min_average_medicare_payments: '301',
          max_average_medicare_payments: '499',
          min_discharges: '11',
          max_discharges: '19',
          state: 'CO',
        }

        it 'should return no providers' do
          providers = query.filter(default_scope, params)
          expect(providers.size).to eq(0)
        end
      end
    end
  end
end
