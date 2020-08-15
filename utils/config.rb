require 'ostruct'
require 'yaml'

class Config
    def self.load(config_path)
        OpenStruct.new(YAML.load_file(config_path).to_h)        
    end
end