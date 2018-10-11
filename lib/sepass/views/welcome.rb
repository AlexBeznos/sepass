require "sepass/view/controller"

module Sepass
  module Views
    class Welcome < Sepass::View::Controller
      configure do |config|
        config.template = "welcome"
      end
    end
  end
end
