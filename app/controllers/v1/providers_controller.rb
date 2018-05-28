module V1
  class ProvidersController < ApiController
    def index
      query = Queries::ProviderQuery.new
      providers = query.filter(params)

      if query.errors.any?
        render status: :bad_request, json: query.errors
        return
      end

      render json: providers
    end
  end
end
