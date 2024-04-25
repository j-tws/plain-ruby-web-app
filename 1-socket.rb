require 'socket'

server = TCPServer.new(1337)

loop do
  client = server.accept

  client.puts "What's your name?"
  input = client.gets
  puts "received #{input.chomp} from a client socket on 1337"
  client.puts "Hi, #{input.chomp}! You've successfully connected to the server socket"

  puts "Closing client socket"
  client.puts "Goodbye #{input}"
  client.close
end