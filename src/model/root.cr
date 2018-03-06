require "morganite"
require "markdown"
require "stout"
require "html"

alias M = Morganite::Morganite

class Root
  include Stout::Magic

  @@content : String?

  def self.routes(server)
    server.get("/", &.<<(Root.new.render))
  end

  def navbar
    M.new.div class: "navbar container" { yield }
  end

  def layout
    M.yield {
      html {
        [
          head {
            [
              title { "Welcome to Stout!" },
              link(rel: "stylesheet", href: "/clean.css"),
              link(rel: "stylesheet", href: "/app.css"),
            ].join
          },
          body {
            [
              div class: "main container" {
                div { yield }
              },
            ].join
          },
        ].join
      }
    }
  end

  def render : String
    unless @@content
      STDERR.puts "memoization failed... rebuilding"

      begin
        file = File.read({{__DIR__}} + "/../../lib/stout/README.md")
        markdown = Markdown.to_html(file)
      rescue e
        puts e
      end

      @@content = markdown.try &.split("<hr/>")[0]
    end

    layout { @@content }
  end
end
