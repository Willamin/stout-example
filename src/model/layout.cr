class Layout
  property context : Stout::Context
  property m : Morganite::Morganite

  def initialize(@context)
    @m = Morganite::Morganite.new
  end

  def to_s
    build {
      yield
    }
  end

  def nav_link(uri : String, text : String)
    if context.request.path == uri
      current_text = m.span(class: "sr-only") { "(current)" }
      current_class = "active"
    else
      current_text = ""
      current_class = ""
    end

    m.li class: "nav-item #{current_class}" {
      m.a(class: "nav-link", href: uri) {
        [
          text,
          current_text,
        ].join
      }
    }
  end

  def head
    m.head {
      [
        m.meta(charset: "utf-8"),
        m.meta(content: "width=device-width, initial-scale=1, shrink-to-fit=no", name: "viewport"),
        m.link(
          rel: "stylesheet",
          href: "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css",
          integrity: "sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm",
          crossorigin: "anonymous"),
        m.title { "Welcome to Stout!" },
      ].join
    }
  end

  def navbar
    Morganite::Morganite.yield {
      nav class: "navbar navbar-expand-sm navbar-light bg-light" {
        [
          a class: "navbar-brand", href: "#" { "Stout" },
          %[<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">],
          span(class: "navbar-toggler-icon"),
          %[</button>],
          div class: "collapse navbar-collapse", id: "navbarSupportedContent" {
            ul class: "navbar-nav mr-auto" {
              [
                nav_link("/", "Home"),
                nav_link("/users", "Users"),
              ].join
            }
          },
        ].join
      }
    }
  end

  def body
    m.body {
      [
        m.div class: "container" {
          m.div { yield }
        },
      ].join
    }
  end

  def post_body
    [
      %[<script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>],
      %[<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>],
      %[<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>],
    ].join
  end

  def build
    [
      "<!doctype html>",
      m.html lang: "en" {
        [
          head,
          m.body {
            [
              navbar,
              body { yield },
              post_body,
            ].join
          },
        ].join
      },
    ].join
  end
end
