require "granite_orm/adapter/pg"

class User < Granite::ORM::Base
  adapter pg
  field email : String
  field password : String

  property email : String?
  property password : String?

  def self.routes(server)
    server.post("/users/create", :users_create, &->create(Stout::Context))
    server.get("/users", :users_index, &->index(Stout::Context))
    server.get("/users/:id", :users_show, &->view(Stout::Context))
    server.get("/users/new", :users_new, &->neww(Stout::Context))
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
    context << Layout.new(context).to_s {
      if u
        "#{u.email}\n"
      else
        "that user wasn't found"
      end
    }
  rescue e
    context << e
  end

  def self.neww(context : Stout::Context)
    context << Layout.new(context).to_s {
      Morganite::Morganite.yield {
        form(method: "post", action: context.path(:users_create)) {
          [
            div class: "form-group" {
              [
                label for: "email" { "Email" },
                input type: "email", class: "form-control", id: "email", name: "email",
              ].join
            },
            div class: "form-group" {
              [
                label for: "password" { "Password" },
                input type: "password", class: "form-control", id: "password", name: "password",
              ].join
            },
            div class: "form-group" {
              [
                label for: "password-confirmation" { "Password Confirmation" },
                input type: "password", class: "form-control", id: "password-confirmation", name: "password-confirmation",
              ].join
            },
            input type: "submit", class: "btn btn-primary",
          ].join
        }
      }
    }
  end

  def self.create(context : Stout::Context)
    context << Layout.new(context).to_s {
      Morganite::Morganite.yield {
        h1 { "Thanks for joining" }
      }
    }
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
