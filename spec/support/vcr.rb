require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false

  config.ignore_localhost = true

  config.filter_sensitive_data('<API_KEY>') { ENV['API_KEY'] }
end
