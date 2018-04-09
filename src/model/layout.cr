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
        %[<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha256-LA89z+k9fjgMKQ/kq4OO2Mrf8VltYml/VES+Rg0fh20=" crossorigin="anonymous" />],
        %[<link rel="stylesheet" href="/app.css" />],
        m.title { "Welcome to Stout!" },
      ].join
    }
  end

  def navbar
    Morganite::Morganite.yield {
      nav class: "navbar navbar-expand-sm navbar-dark bg-dark sticky-top" {
        div class: "container" {
          [
            a class: "navbar-brand", href: "#" { "Stout" },
            %[<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">],
            span(class: "navbar-toggler-icon"),
            %[</button>],
            div class: "collapse navbar-collapse", id: "navbarSupportedContent" {
              ul class: "navbar-nav mr-auto" {
                [
                  nav_link(context.path(:root), "Home"),
                  nav_link(context.path(:users_index), "Users"),
                  nav_link(context.path(:users_new), "Create a User"),
                ].join
              }
            },
          ].join
        }
      }
    }
  end

  def body
    m.body {
      [
        # m.img(src: "/hero.jpg", class: "hero img-fluid", alt: "Responsive image"),
        m.div(class: "blank"),
        m.div class: "container page" {
          m.div { yield }
        },
        m.div(class: "blank-bottom"),
      ].join
    }
  end

  def post_body
    [
      %[<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap.native/2.0.21/bootstrap-native-v4.min.js" integrity="sha256-NZzruTlTqj1lzF2YS5Djc/M8mk464nFUGtQ3QWxBEsU=" crossorigin="anonymous"></script>],
      # %[<script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>],
      # %[<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>],
      # %[<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>],
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

  def self.routes(server)
    server.get("/hero.jpg", &->hero(Stout::Context))
  end

  def self.hero(context)
    file_path = {{__DIR__}} + "/../static/hero.jpg"
    puts file_path
    context.response.content_type = "image/jpeg"
    context.response.content_length = File.size(file_path)

    context.response.headers.add("Cache-Control", "max-age=3600")
    context.response.headers.add("Cache-Control", "public")

    File.open(file_path) do |file|
      IO.copy(file, context.response)
    end

    context.response.flush
  end
end
