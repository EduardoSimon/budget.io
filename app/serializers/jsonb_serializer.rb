class JsonbSerializer
  def self.dump(obj)
    obj.to_json
  end

  def self.load(json)
    JSON.parse(json, symbolize_names: true) if json.instance_of?(String)
  end
end
