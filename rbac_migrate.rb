require 'net/http'
require 'uri'
require 'json'
require 'pry'

def get_rbac(token, hostname, filename)
  uri = URI.parse("https://" + hostname.strip + ":4433/rbac-api/v1/roles?token=#{token}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri)

  response = http.request(request)

  json = JSON.parse(response.body)
  File.open(filename.strip,"w") do |f|
    f.write(json.to_json)
  end
end

def push_rbac(token, hostname, filename)
  removes = ['Administrators', 'Operators', 'Viewers', 'Code Deployers', 'Project Deployers']
  
  uri = URI.parse("https://" + hostname.strip + ":4433/rbac-api/v1/roles?token=#{token}")

  file = File.read(filename.strip)
  data_hash = JSON.parse(file, {:symbolize_names => true})
  
  # Clean out the unneeded roles
  removes.each { |remove| data_hash.delete_if { |hash| hash[:display_name] == remove}} 

  header = {'Content-Type': 'application/json'}

  # Create the HTTP objects
  for index in 0 ... data_hash.size
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = data_hash[index].to_json

    # Send the request
    response = http.request(request)
    puts response
  end
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