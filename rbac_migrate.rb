require 'open-uri'
require 'net/http'
require 'uri'
require 'json'
#require 'pry' # For debugging 

def get_rbac(token, hostname, filename)
  response = open("https://" + hostname.strip + ":4433/rbac-api/v1/roles?token=#{token}", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
  json = JSON.parse(response)
  File.open(filename.strip,"w") do |f|
    f.write(json.to_json)
  end
end

def push_rbac(token, hostname, filename)
  removes = ['Administrators', 'Operators', 'Viewers', 'Code Deployers', 'Project Deployers']
  
  uri = URI.parse("https://" + hostname.strip + ":4433/rbac-api/v1/roles?token=#{token}")
  header = {'Content-Type': 'application/json'}

  file = File.read(filename.strip)
  data_hash = JSON.parse(file, {:symbolize_names => true})
  
  # Clean out the unneeded roles
  removes.each { |remove| data_hash.delete_if { |hash| hash[:display_name] == remove}} 

  # Create the HTTP objects  
  for index in 0 ... data_hash.size
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = data_hash[index].to_json

    # Blank the user and group id's to avoid conflict
    data_hash[index][:user_ids]=[]
    data_hash[index][:group_ids]=[]

    # Send the request
    response = http.request(request)
    puts "RBAC grooup #{data_hash[index][:display_name]} status #{response}"
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