# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'securerandom'
require 'dotenv'

Dotenv.load

API_SECRET_TOKEN = ENV['API_SECRET_TOKEN']

before do
  authenticate_request!
end

get '/' do
  'Hello world!'
end

post '/validate' do
  # Receive uploaded file
  file = params[:file]

  # Ensure a file is uploaded
  halt 400, { status: 'error', message: 'File missing' }.to_json unless file

  # Validate file format
  if valid_file_format?(file[:filename])
    # sleep 60

    # Randomly return valid or invalid
    status = random_status
    { status: status }.to_json
  else
    halt 400, { status: 'error', message: 'Unsupported file format' }.to_json
  end
end

# Helper method to validate file formats
def valid_file_format?(filename)
  allowed_formats = %w[.pdf .jpg .jpeg .png]
  extension = File.extname(filename).downcase
  allowed_formats.include?(extension)
end

# Helper method to generate random status
def random_status
  SecureRandom.random_number(2).zero? ? 'valid' : 'invalid'
end

def authenticate_request!
  token = request.env['HTTP_AUTHORIZATION']

  return if token && token == "Bearer #{API_SECRET_TOKEN}"

  halt 401, { status: 'error', message: 'Unauthorized' }.to_json
end
