module V1
  class ProvidersController < ApiController
    def index
      providers = Provider.first(2)
      id_to_state_code_hash = State.id_to_state_code_hash
      render json: ActiveModelSerializers::SerializableResource.new(
        providers,
        scope: {
          id_to_state_code_hash: id_to_state_code_hash,
        },
      ).as_json
    end
  end
end
