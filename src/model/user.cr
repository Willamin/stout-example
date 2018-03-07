require "granite_orm/adapter/pg"

class User < Granite::ORM::Base
  adapter pg
  field email : String
  field password : String

  property email : String?
  property password : String?

  def self.routes(server)
    server.get("/users", &->index(Stout::Context))
    server.get("/users/:id", &->view(Stout::Context))
  end

  def self.index(context : Stout::Context)
    users = User.all

    context << Layout.new(context).to_s {
      users.try &.each do |u|
        u.email
      end

      if users.size == 0
        "no users found"
      end
    }
  end

  def self.view(context : Stout::Context)
    u = User.find(context.params["id"])
    if u
      context << u.email
      context << "\n"
    else
      context << "that user wasn't found"
    end
  rescue e
    context << e
  end

  def self.schema
    <<-SQL
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR,
  password VARCHAR,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
SQL
  end
end
