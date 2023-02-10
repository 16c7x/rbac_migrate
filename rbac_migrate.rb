require 'open-uri'
require 'net/http'
require 'uri'
require 'json'
require 'pry'

def get_rbac(token, hostname, filename)
  response = open("https://" + hostname.strip + ":4433/rbac-api/v1/roles?token=#{token}", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
  json = JSON.parse(response)
  File.open(filename.strip,"w") do |f|
    f.write(json.to_json)
  end
end

def push_rbac(token, hostname, filename)
  uri = URI.parse("https://" + hostname.strip + ":4433/rbac-api/v1/roles?token=#{token}")

  file = File.read(filename.strip)
  data_hash = JSON.parse(file)

  header = {'Content-Type': 'application/json'}

  # Create the HTTP objects
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.body = data_hash[5].to_json

  # Send the request
  response = http.request(request)

end

puts "Enter the API token: "
token = gets

puts "Enter the hostname (e.g. localhost): "
hostname = gets

puts "Enter target/source file (.json): "
filename = gets

puts "Are we getting the RBAC config or pushing it? [get|push]"
action = gets

action.gsub("\n",'')

case action.strip
when "push"
  push_rbac(token, hostname, filename)
when "get"
  get_rbac(token, hostname, filename)
else
  puts "Invalid input, choose either push or pull"
end