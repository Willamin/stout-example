require "stout"
Stout::Magic.deft

require "./model/*"

server = Stout::Server.new

Root.routes(server)

server.listen
