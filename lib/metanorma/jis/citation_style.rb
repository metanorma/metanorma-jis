require "metanorma/iso/citation_style"

module Metanorma
  module Jis
    #
    # The JIS flavor's citation renderer: the ISO facade with this
    # flavor's style file (the home-docid set, the Japanese labels, and
    # the JIS reference terminator). Supersedes the stack this gem
    # carried under lib/relaton/render-jis, which subclassed the
    # metanorma-iso render internals that main no longer ships.
    #
    class CitationStyle < ::Metanorma::Iso::CitationStyle
      STYLE_PATH = File.join(__dir__, "jis-style.yml")

      def initialize(options = {})
        super(options.merge(style: STYLE_PATH))
      end

      # Japanese references carry no terminal period; the superseded
      # stack stripped it from every rendering (render-jis general.rb)
      def render_all(bib, type: "author-date")
        ret = super
        ret&.each_value { |k| k[:formattedref]&.sub!(/[.。]\s*\z/, "") }
        ret
      end
    end
  end
end
