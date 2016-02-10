require 'yaml'

module TestCredentials
  DEFAULT_PATH = File.dirname(File.expand_path(__FILE__)) + '/../credentials.yml'

  def credentials(path = DEFAULT_PATH)
    YAML.load_file(path)
  end
end

RSpec.configure do |config|
  config.include TestCredentials
end
