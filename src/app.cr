require "yaml"
require "stout"
Stout::Magic.deft
require "granite/base"
require "db"
require "granite/adapter/pg"

database = YAML.parse(File.read({{__DIR__}} + "/../config/database.yml"))["pg"]["database"].as_s

Granite::Adapters << Granite::Adapter::Pg.new({name: "postgres", url: database})

require "./model/*"

DB.open database do |db|
  db.exec User.schema
rescue e : PQ::PQError
  if e.field_message(:code) != "42P07" # duplicate table error
    raise e
  end

  puts "table already exists"
end

server = Stout::Server.new
server.default_route = "/"

Root.routes(server)
User.routes(server)
Layout.routes(server)

Stout::Cli.handle(server)

server.listen
