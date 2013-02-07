env_config = File.expand_path('../env_constants.yml', __FILE__)
if File.exists?(env_config)
  config = YAML.load_file(env_config)
  config.fetch(Rails.env, {}).each do |key, value|
    ENV[key.upcase] = value.to_s
  end
end