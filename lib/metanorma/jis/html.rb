# frozen_string_literal: true

require "metanorma/iso/html"

module Metanorma
  module Jis
    # HTML format slice for the flavor: the renderer, registered with
    # the harness from jis/document.rb. Renders iso-style; the JIS root
    # uses the ISO section classes (parent-registered) plus the JIS
    # annex.
    module Html
      autoload :Renderer, "#{__dir__}/html/renderer"
    end
  end
end
