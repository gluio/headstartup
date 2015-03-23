require "headstartup/version"
require "nesta/config"
require "nesta/app"

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
end

module Headstartup
  class App < Nesta::App
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

