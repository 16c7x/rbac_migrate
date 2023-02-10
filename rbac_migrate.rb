require 'net/http'
require 'uri'
require 'json'
require 'pry'

def get_rbac(token, hostname, filename)
  puts "getting"
  puts token
  puts hostname
  puts filename

  response = open("https://localhost:4433/rbac-api/v1/roles?token=0UYhSXdTV0VEQC_22WA8fxtJ_swYbXrzp1Us2idrKz8w", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read

  json = JSON.parse(response)

  File.open("rbac_groups.json","w") do |f|
    f.write(json.to_json)
  end
end

def push_rbac(token, hostname, filename)
  puts "putting"

  file = File.read('./rbac_groups.json')
  data_hash = JSON.parse(file)
  payload = data_hash[5]

  uri = URI.parse("https://localhost:4433/rbac-api/v1/roles?token=0UYhSXdTV0VEQC_22WA8fxtJ_swYbXrzp1Us2idrKz8w")

  header = {'Content-Type': 'application/json'}

  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.body = payload.to_json

  response = http.request(request)
end

puts "Enter the API token: "
token = gets

puts "Enter the hostname (e.g. localhost): "
hostname = gets

puts "Enter source file: "
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