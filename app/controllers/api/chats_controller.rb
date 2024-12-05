require 'net/http'
require 'uri'

# backend/app/controllers/api/chat_controller.rb
class Api::ChatsController < ApplicationController
  include ActionController::Streaming

  def create
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['Connection'] = 'keep-alive'

    uri = URI(ENV['PYTHON_SERVER_URL'] + '/chat')
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = { message: params[:message] }.to_json

    begin
      http.request(request) do |python_response|
        python_response.read_body do |chunk|
          response.stream.write(chunk)
        end
      end
    ensure
      response.stream.close
    end
  end
end