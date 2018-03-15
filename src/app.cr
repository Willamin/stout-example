require "yaml"
require "stout"
Stout::Magic.deft

require "./model/*"

database = YAML.parse(File.read({{__DIR__}} + "/../config/database.yml"))["pg"]["database"].as_s

DB.open database do |db|
  db.exec User.schema
rescue e : PQ::PQError
  if e.field_message(:code) != "42P07" # duplicate table error
    raise e
  end

  puts "table already exists"
end

def draw_routes(tree, prefix = "")
  me = prefix + tree.key
  puts me
  tree.children.each do |c|
    draw_routes(c, me)
  end
end

server = Stout::Server.new

Root.routes(server)
User.routes(server)
Layout.routes(server)

puts "routes:"
draw_routes(server.routes.root)

server.listen
