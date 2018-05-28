class ApiController < ActionController::API
  serialization_scope :context

  def context
    OpenStruct.new({
      params: params,
    })
  end
end
