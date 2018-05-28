module V1
  class ProvidersController < ApiController
    def index
      render inline: 'foo'
    end
  end
end
