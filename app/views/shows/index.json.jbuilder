json.array!(@shows) do |show|
  json.extract! show, :id, :name, :overview, :tvdb_id
  json.url show_url(show, format: :json)
end
