module Farscape

  CONFIGURATION_FILE_PATH = 'config/farscape.yml'

  # This class manages the configuration from the Farscape config file.
  # This class is totally unrelated to Farscape::Configuration even when the names are similar
  # TODO: Rename this or that or do something about this.
  class ConfigFile
    def configuration
      default_config = {
        default_accept: 'application/vnd.hale+json'
      }
      default_config.merge!(config_data)
    end

    private
    def config_data
      config_hash = symbolize_keys(YAML::load(IO.read(Dir.glob(CONFIGURATION_FILE_PATH).first.to_s)))
    rescue Errno::ENOENT
      puts "YAML configuration file couldn't be found in #{CONFIGURATION_FILE_PATH}."
    rescue Psych::SyntaxError
      puts "YAML configuration file contains invalid syntax."
    ensure #return is needed here or this method would return nil on exceptions
      return config_hash || {}
    end

    def symbolize_keys(hash)
      hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    end
  end
end
