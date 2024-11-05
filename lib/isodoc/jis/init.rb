require "isodoc"
require_relative "metadata"
require_relative "i18n"

module IsoDoc
  module Jis
    module Init
      def metadata_init(lang, script, locale, labels)
        @meta = Metadata.new(lang, script, locale, labels)
      end

      def xref_init(lang, script, _klass, labels, options)
        p = HtmlConvert.new(language: lang, script: script)
        @xrefs = Xref.new(lang, script, p, labels, options)
      end

      def i18n_init(lang, script, locale, i18nyaml = nil)
        @i18n = I18n.new(lang, script, locale: locale,
                                       i18nyaml: i18nyaml || @i18nyaml)
      end

      def bibrenderer(options = {})
        ::Relaton::Render::Jis::General.new(options.merge(language: @lang,
                                                          i18nhash: @i18n.get))
      end

      def std_docid_semantic(text)
        text
      end
    end
  end
end
