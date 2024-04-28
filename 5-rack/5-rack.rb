require 'pry'
require 'yaml/store'
require 'rack/handler/puma'
require 'rack'

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

app = ->(environment) {
  request = Rack::Request.new(environment)
  response = Rack::Response.new

  if request.get? && request.path == '/get/secrets'
    response.content_type = 'text/html'
    response.write("<ul>\n")

    store.transaction do
      store['secrets'].each do |secret|
        response.write("<li> #{secret[:pen_name]}</b> secret: #{secret[:secret]}")
      end
    end

    response.write("</ul>\n")
    response.write(<<~FORM
        <form action="/add/secrets" method="post" enctype="application/x-www-form-urlencoded">
          <p><label>Pen Name <input type="text" name="pen-name"></label></p>
          <p><label>Secret <input type="text" name="secret"></label></p>
          <p><button>Submit secret</button></p>
        </form>
      FORM
    )
  elsif request.post? && request.path == '/add/secrets'
    response.content_type = 'text/html'

    new_secret = request.params
    store.transaction do
      store['secrets'] << Secret.new(new_secret['pen-name'], new_secret['secret'])
    end

    response.redirect('/get/secrets', 303)
  else
    response.content_type = 'text/plain; charset=UTF-8'
    response.write("✅Received a #{request.request_method} request to #{request.path} with #{request.env['HTTP_VERSION']}")
  end

  # Mark response as finish
  response.finish
}

Rack::Handler::Puma.run(app, Port: 1337, Verbose: true)
