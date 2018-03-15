require "morganite"
require "markdown"
require "stout"
require "html"

class Root
  include Stout::Magic

  @@content : String?

  def self.routes(server)
    server.get("/", &->render(Stout::Context))
  end

  def self.render(context)
    unless @@content
      STDERR.puts "memoization failed... rebuilding"

      begin
        file = File.read({{__DIR__}} + "/../../lib/stout/README.md")
        markdown = Markdown.to_html(file)
      rescue e
        puts e
      end

      @@content = markdown.try(&.split("<hr/>")[0])
    end

    context << Layout.new(context).to_s { @@content }
  end
end
