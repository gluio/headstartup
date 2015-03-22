require "headstartup/version"
require "nesta/config"
require "nesta/app"

module Headstartup
  class Config < Nesta::Config
    def self.page_path(basename = nil)
      get_path(File.join(content_path, "landing-pages"), basename)
    end
  end

  class App < Nesta::App
  end
end
