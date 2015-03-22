module Nesta
  class App
    # Uncomment the Rack::Static line below if your theme has assets
    # (i.e images or JavaScript).
    #
    # Put your assets in themes/glu-io-startup/public/glu-io-startup.
    #
    # use Rack::Static, urls: ["/glu-io-startup"], root: "themes/glu-io-startup/public"

    helpers do
      def twitter_handle
        Nesta::Config.fetch("twitter", nil)
      end

      def facebook_page
        Nesta::Config.fetch("facebook", nil)
      end
    end

    # Add new routes here.
  end
end
