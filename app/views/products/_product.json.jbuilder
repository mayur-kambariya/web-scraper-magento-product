json.extract! product, :id, :name, :price, :detail, :extra_info, :created_at, :updated_at
json.url product_url(product, format: :json)
