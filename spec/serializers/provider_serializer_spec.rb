require 'rails_helper'

describe ProviderSerializer do
  describe 'serializing a provider' do
    before do
      @state = FactoryGirl.create(:alabama_state)
      @provider = FactoryGirl.create(:provider, state: @state)
    end

    context 'as json' do
      let(:serializer) { ProviderSerializer.new(@provider) }
      let(:json)       { serializer.as_json }

      it 'should have the correctly formatted keys' do
        expect(json).to have_key('Provider Name')
        expect(json).to have_key('Provider Street Address')
        expect(json).to have_key('Provider City')
        expect(json).to have_key('Provider State')
        expect(json).to have_key('Provider Zip Code')
        expect(json).to have_key('Hospital Referral Region Description')
        expect(json).to have_key('Total Discharges')
        expect(json).to have_key('Average Covered Charges')
        expect(json).to have_key('Average Total Payments')
        expect(json).to have_key('Average Medicare Payments')
      end

      it 'should have the correct provider values' do
        expect(json['Provider Name']).to                        eq(@provider.provider_name)
        expect(json['Provider Street Address']).to              eq(@provider.provider_street_address)
        expect(json['Provider City']).to                        eq(@provider.provider_city)
        expect(json['Provider Zip Code']).to                    eq(@provider.provider_zip_code)
        expect(json['Hospital Referral Region Description']).to eq(@provider.hospital_referral_region_description)
        expect(json['Total Discharges']).to                     eq(@provider.total_discharges)
      end

      it 'should have the correct state code' do
        expect(json['Provider State']).to eq(@state.code)
      end

      it 'should have the correct currency values' do
        expect(json['Average Covered Charges'][0]).to eq('$')
        expect(json['Average Total Payments'][0]).to eq('$')
        expect(json['Average Medicare Payments'][0]).to eq('$')

        expect(json['Average Covered Charges'][-3]).to eq('.')
        expect(json['Average Total Payments'][-3]).to eq('.')
        expect(json['Average Medicare Payments'][-3]).to eq('.')

        expect(json['Average Covered Charges'][-7]).to eq(',')
        expect(json['Average Total Payments'][-7]).to eq(',')
        expect(json['Average Medicare Payments'][-7]).to eq(',')

        expect(json['Average Covered Charges'].gsub(/[$,.]/, '').to_i).to   eq(@provider.average_covered_charges_in_cents)
        expect(json['Average Total Payments'].gsub(/[$,.]/, '').to_i).to    eq(@provider.average_total_payments_in_cents)
        expect(json['Average Medicare Payments'].gsub(/[$,.]/, '').to_i).to eq(@provider.average_medicare_payments_in_cents)
      end
    end
  end
end
