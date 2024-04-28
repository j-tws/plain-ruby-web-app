require 'pry'
require 'sqlite3'
require 'rack/handler/puma'
require 'rack'

# before running the file, run the below in the terminal to create secrets table:
# ------------------------------------------------------
# create table secrets (pen_name TEXT, secret TEXT);
# INSERT INTO secrets VALUES("xXx_SW4G_xXx", "I have a crush on my college course mate");
# INSERT INTO secrets VALUES("confused_me", "I don't know what I am doing in life");
# INSERT INTO secrets VALUES("H4CKER", "I want to hack a bank but idk how");
# ------------------------------------------------------

app = ->(environment) {
  db = SQLite3::Database.new('secrets.sqlite3', results_as_hash: true)

  request = Rack::Request.new(environment)
  response = Rack::Response.new

  if request.get? && request.path == '/get/secrets'
    response.content_type = 'text/html'
    response.write("<ul>\n")

    db.execute('select * from secrets') do |secret|
      response.write("<li> #{secret['pen_name']}</b> secret: #{secret['secret']}")
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
    db.execute("insert into secrets (pen_name, secret) values (?, ?)", [new_secret['pen-name'], new_secret['secret']])

    response.redirect('/get/secrets', 303)
  else
    response.content_type = 'text/plain; charset=UTF-8'
    response.write("✅Received a #{request.request_method} request to #{request.path} with #{request.env['HTTP_VERSION']}")
  end

  # Mark response as finish
  response.finish
}

Rack::Handler::Puma.run(app, Port: 1337, Verbose: true)
