require 'yaml'

module Broview
  class Config
    def self.load_config
      @config ||= YAML.load_file(File.expand_path('../../config/config.yml', __dir__))
    end

    def self.get(key)
      load_config['default'][key.to_s]
    end
  end
end