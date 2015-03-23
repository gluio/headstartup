require "headstartup/version"
require "nesta/config"
require "nesta/app"
require "nesta/overrides"

module Nesta
  class Nesta::Config
    def self.landing_page_path(basename = nil)
      get_path(File.join(content_path, "landing-pages"), basename)
    end
  end

  class LandingPage < Nesta::Page
    def self.model_path(basename = nil)
      Nesta::Config.landing_page_path(basename)
    end
  end

  module Overrides
    public :render_options
    alias_method :render_options_without_headstart, :render_options

    def self.render_options(template, *engines)
      theme_view_path = Nesta::Path.themes('headstartup', 'views')
      local_view_path = Nesta::Path.local("views/landing-pages")
      [local_view_path, theme_view_path].each do |path|
        engines.each do |engine|
          if template_exists?(engine, path, template)
            return { views: path }, engine
          end
        end
      end
      render_options_without_headstart
    end
  end
end

module Headstartup
  class App < Nesta::App
    app_file = Nesta::Path.themes('headstartup', 'app.rb')
    require app_file if File.exist?(app_file)
  end
end

