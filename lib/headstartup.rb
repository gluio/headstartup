require "headstartup/version"
require "nesta/config"
require "nesta/app"

module Headstartup
  class Config < Nesta::Config
    @settings = %w[
      cache
      content
      disqus_short_name
      google_analytics_code
      read_more
      subtitle
      theme
      title
    ]
    @author_settings = %w[name uri email]
    @yaml = nil

    def self.landing_page_path(basename = nil)
      get_path(File.join(content_path, "landing-pages"), basename)
    end
  end

  class LandingPage < Nesta::Page
    def self.model_path(basename = nil)
      Headstartup::Config.landing_page_path(basename)
    end
  end

  module Overrides
    module Renderers
      def haml(template, options = {}, locals = {})
        defaults, engine = Headstartup::Overrides.render_options(template, :haml)
        super(template, defaults.merge(options), locals)
      end

      def erb(template, options = {}, locals = {})
        defaults, engine = Headstartup::Overrides.render_options(template, :erb)
        super(template, defaults.merge(options), locals)
      end

      def scss(template, options = {}, locals = {})
        defaults, engine = Headstartup::Overrides.render_options(template, :scss)
        super(template, defaults.merge(options), locals)
      end

      def sass(template, options = {}, locals = {})
        defaults, engine = Headstartup::Overrides.render_options(template, :sass)
        super(template, defaults.merge(options), locals)
      end

      def stylesheet(template, options = {}, locals = {})
        defaults, engine = Headstartup::Overrides.render_options(template, :sass, :scss)
        renderer = Sinatra::Templates.instance_method(engine)
        renderer.bind(self).call(template, defaults.merge(options), locals)
      end
    end

    private
      def self.template_exists?(engine, views, template)
        views && File.exist?(File.join(views, "#{template}.#{engine}"))
      end

      def self.render_options(template, *engines)
        [local_view_path, theme_view_path].each do |path|
          STDOUT.puts "Path is: #{path}"
          STDOUT.puts "Looking for template: #{template}"
          engines.each do |engine|
            if template_exists?(engine, path, template)
              STDOUT.puts "Path exists: #{path}"
              return { views: path }, engine
            end
          end
        end
        [{}, :sass]
      end

      def self.local_view_path
        Headstartup::App.views
      end

      def self.theme_view_path
        if Nesta::Config.theme.nil?
          nil
        else
          Nesta::Path.themes(Nesta::Config.theme, "views")
        end
      end
  end

  class App < Nesta::App
    set :root, File.expand_path(File.dirname(__FILE__))
    set :views, File.expand_path("views", File.dirname(__FILE__))

    helpers Headstartup::Overrides::Renderers

    get '/sitemap.xml' do
      content_type :xml, charset: 'utf-8'
      @pages = LandingPage.find_all.reject do |page|
        page.draft? or page.flagged_as?('skip-sitemap')
      end
      @last = @pages.map { |page| page.last_modified }.inject do |latest, page|
        (page > latest) ? page : latest
      end
      haml(:sitemap, format: :xhtml, layout: false)
    end

    get '*' do
      set_common_variables
      parts = params[:splat].map { |p| p.sub(/\/$/, '') }
      @page = LandingPage.find_by_path(File.join(parts))
      raise Sinatra::NotFound if @page.nil?
      @title = @page.title
      set_from_page(:description, :keywords)
      haml(@page.template, layout: @page.layout)
    end
  end
end

