module AhoyCaptain
  class Railtie < ::Rails::Railtie
    initializer "ahoy_captain.assets.precompile" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.precompile += %w[ahoy_captain/manifest]
      end
    end
  end
end
