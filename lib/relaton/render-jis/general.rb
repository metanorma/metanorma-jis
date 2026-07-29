require "relaton-render"
require "metanorma-iso"

module Relaton
  module Render
    module Jis
      class General < ::Relaton::Render::Iso::General
        def config_loc
          YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))
        end

        def klass_initialize(_options)
          super
          @parseklass = Relaton::Render::Jis::Parse
          @fieldsklass = Relaton::Render::Jis::Fields
        end

        def render_all(bib, type: "author-date")
          ret = super
          ret&.each_value { |k| k[:formattedref]&.sub!(/[.。]\s*$/, "") }
          ret
        end
      end
    end
  end
end
