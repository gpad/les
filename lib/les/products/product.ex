defmodule Les.Products.Product do

  @enforce_keys [:description, :provider, :ext_id, :price, :qty]
  defstruct [
    id: UUID.uuid4(),
    description: "",
    provider: nil,
    ext_id: nil,
    price: nil,
    qty: nil,
  ]
end
