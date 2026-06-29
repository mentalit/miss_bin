Label recognition service · RB
# app/services/label_recognition_service.rb
require "net/http"
require "json"
require "base64"
 
class LabelRecognitionService
  API_URL         = "https://api.anthropic.com/v1/messages"
  MODEL           = "claude-opus-4-6"
  MAX_TOKENS      = 100
  ANTHROPIC_VERSION = "2023-06-01"
 
  class ApiError < StandardError; end
 
  # Returns the raw string from the API (digits only after sanitisation in caller)
  def self.extract_artno(base64_image, media_type: "image/jpeg")
    uri  = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 15
    http.open_timeout = 5
 
    request = Net::HTTP::Post.new(uri.path)
    request["Content-Type"]       = "application/json"
    request["x-api-key"]          = ENV.fetch("ANTHROPIC_API_KEY")
    request["anthropic-version"]  = ANTHROPIC_VERSION
 
    request.body = {
      model:      MODEL,
      max_tokens: MAX_TOKENS,
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image",
              source: {
                type:       "base64",
                media_type: media_type,
                data:       base64_image
              }
            },
            {
              type: "text",
              text: <<~PROMPT
                Look at this IKEA product box label.
                Find the article number — it appears as a dot-separated number like 902.638.60 or 202.055.38, usually inside a dark rectangle beneath the product name.
                Return ONLY the digits with no dots, spaces, or any other characters.
                If you cannot read a clear article number, return the word UNREADABLE and nothing else.
              PROMPT
            }
          ]
        }
      ]
    }.to_json
 
    response = http.request(request)
 
    unless response.is_a?(Net::HTTPSuccess)
      raise ApiError, "HTTP #{response.code}: #{response.body}"
    end
 
    body = JSON.parse(response.body)
    text = body.dig("content", 0, "text").to_s.strip
 
    raise ApiError, "Empty response from API" if text.empty?
 
    text
  rescue Net::TimeoutError, Net::OpenTimeout => e
    raise ApiError, "Timeout: #{e.message}"
  rescue JSON::ParserError => e
    raise ApiError, "JSON parse error: #{e.message}"
  end
end
