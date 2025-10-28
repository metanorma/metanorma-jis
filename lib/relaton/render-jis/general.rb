require "relaton-render"
require "metanorma-iso"
require "isodoc"
require_relative "parse"
require_relative "fields"

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

        # KILL
        def render1x(doc, terminator)
          r = doc.relation.select { |x| x.type == "hasRepresentation" }
            .map { |x| @i18n.also_pub_as + render_single_bibitem(x.bibitem) }
          out = [render_single_bibitem(doc)] + r
          @i18n.l10n(out.join(". ").gsub(/[.。]\. /, ". ").sub(/[.。]\s*$/, ""))
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
