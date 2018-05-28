require 'rails_helper'

RSpec.describe 'provider routes', type: :routing do
  describe 'route versioning' do
    it { expect(get("/providers")).to route_to('v1/providers#index') }
    it { expect(get("/v1/providers")).to route_to("v1/providers#index") }
  end
end
