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
      Morganite::Morganite.yield {
        if users.size == 0
          [h1 { "Users" }, p { "no users found" }].join
        else
          [
            h1 { "Users" },
            ul {
              users.try &.map { |u| li { u.email } }.join
            },
          ].join
        end
      }
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

  def self.neww(context : Stout::Context, previous_email : String? = nil, pass_message : String? = nil)
    context << Layout.new(context).to_s {
      Morganite::Morganite.yield {
        form(method: "post", action: context.path(:users_create)) {
          [
            div class: "form-group" {
              [
                label for: "email" { "Email" },
                input type: "email", class: "form-control", id: "email", name: "email", value: previous_email.to_s,
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
                if pass_message
                  span class: "pass-message" { pass_message }
                end,
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
    password = context.data.not_nil!["password"].as_s
    password_confirmation = context.data.not_nil!["password-confirmation"].as_s
    email = context.data.not_nil!["email"].as_s

    unless password == password_confirmation
      context.response.status_code = 400
      neww(context, email, "passwords don't match")
      return
    end

    user = User.new
    user.email = email
    user.password = password
    unless user.save
      raise "User save error"
    end

    context << Layout.new(context).to_s {
      Morganite::Morganite.yield {
        [
          h1 { "Thanks for joining" },
        ].join
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
