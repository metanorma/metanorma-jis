require "relaton-render"
require "metanorma-iso"

module Relaton
  module Render
    module Jis
      autoload :General, "relaton/render-jis/general"
      autoload :Parse, "relaton/render-jis/parse"
      autoload :Fields, "relaton/render-jis/fields"
    end
  end
end
