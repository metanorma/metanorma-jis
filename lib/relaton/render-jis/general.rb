require "relaton-render"
require "metanorma-iso"
require "isodoc"
require_relative "parse"

module Relaton
  module Render
    module JIS
      class General < ::Relaton::Render::Iso::General
        def config_loc
          YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))
        end

        def klass_initialize(_options)
          super
          @parseklass = Relaton::Render::JIS::Parse
        end

        def render1(doc)
          r = doc.relation.select { |x| x.type == "hasRepresentation" }
            .map { |x| @i18n.also_pub_as + render_single_bibitem(x.bibitem) }
          out = [render_single_bibitem(doc)] + r
          @i18n.l10n(out.join(". ").gsub(".. ", ". ").sub(/\.\s*$/, ""))
        end

        def render_all(bib, type: "author-date")
          ret = super
          ret.each_value { |k| k[:formattedref].sub!(/[.。]\s*$/, "") }
          ret
        end
      end
    end
  end
end
