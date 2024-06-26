require 'socket'
require 'pry'
require 'uri'
require 'yaml/store'

server = TCPServer.new(1337)

Secret = Struct.new(:pen_name, :secret)

store = YAML::Store.new("secrets.yml")

unless File.file?('secrets.yml')
  secrets = [
    Secret.new('xXx_SW4G_xXx', 'I have a crush on my college course mate'),
    Secret.new('confused_me', "I don't know what I am doing in life"),
    Secret.new('H4CKER', 'I want to hack a bank but idk how'),
  ]

  store.transaction { store["secrets"] = secrets }
end

loop do
  client = server.accept

  request_line = client.readline
  method_token, target, version_number = request_line.split

  case [method_token, target]
  when ['GET', '/get/secrets']
    # endpoint for GET /show/secrets
    response_status_code = '200 OK'
    content_type = 'text/html'
    response_message = ''

    response_message << "<ul>\n"
    store.transaction do
      store['secrets'].each do |secret|
        response_message << "<li> #{secret[:pen_name]}</b> secret: #{secret[:secret]}"
      end
    end
    # secrets.each do |secret|
    #   response_message << "<li> #{secret[:pen_name]}</b> secret: #{secret[:secret]}"
    # end

    response_message << "</ul>\n"
    response_message << <<~FORM
      <form action="/add/secrets" method="post" enctype="application/x-www-form-urlencoded">
        <p><label>Pen Name <input type="text" name="pen-name"></label></p>
        <p><label>Secret <input type="text" name="secret"></label></p>
        <p><button>Submit secret</button></p>
      </form>
    FORM

  when ['POST', '/add/secrets']
    # endpoint for POST /add/secrets
    response_status_code = "303 See Other"
    content_type = "text/html"
    response_message = ""

    # Break apart header fields to get the
    # Content-Length which help us get the body
    # of the message
    all_headers = {}
    loop do
      line = client.readline
      break if line == "\r\n"
      header_name, value = line.split(": ")
      all_headers[header_name] = value
    end
    body = client.read(all_headers['Content-Length'].to_i)

    new_secret = URI.decode_www_form(body).to_h
    store.transaction do 
      store['secrets'] << Secret.new(new_secret['pen-name'], new_secret['secret'])
    end
  else
    response_status_code = '200 OK'
    response_message = "✅Received a #{method_token} request to #{target} with #{version_number}"
    content_type = 'text/plain'
  end

  puts response_message

  # Construct the HTTP Response
  http_response = <<~RESPONSE
    #{version_number} #{response_status_code}
    Content-Type: #{content_type}; charset=#{response_message.encoding.name}
    Location: /get/secrets

    #{response_message}
  RESPONSE

  client.puts http_response
  client.close
end
