require 'farscape/client/http_client'

module Farscape

  def self.clients
    @clients ||= {http: Farscape::Agent::HTTPClient}
  end

end
