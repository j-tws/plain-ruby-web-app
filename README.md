# Web App in plain ruby

## Part 1 - Socket
1. `socket` library creates a TCP server socket.
2. Create a loop and accepts any client in it through `.accept`
3. After responding to client, close the connection

## Part 2 - HTTP with the network
1. Web browser speaks in HTTP (hypertext transfer protocol)
2. (lower level) IP > TCP > HTTP (higher application level)
3. HTTP message have the same structure:
  - a start (request) line
  - zero or more headers
  - a blank line
  - an optional message body

## Part 3 - Response
1. The only difference between the request structure is the first line is a *response* line with status code

## Part 4 - Persistent data storage
- Uses `yaml/store` to store data in a yml file

## Part 5 - Rack
1. A Rack application is any ruby object that response to the `#call` message, which accepts a hash as an argument called the environment, and always return a three-element array which contains:
- a status code
- hash of response headers
- an array of the response body
2. Example: `[200, {'Content-Type' => 'text/plain'}, ['hello world!']]`
3. Rack serves as a middleware between your application, which allow the server to intercept HTTP request on the web application's behalf and return the three element array

## Part 6 - Persistent data storage (for real)
- Uses a database management (sqlite3) to store data

## Part 7 - MVC
- Utilizes rails mvc pattern with `activerecord`, `activecontroller` and `activeview` to create an mvc pattern