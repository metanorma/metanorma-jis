require "isodoc"
require "metanorma-iso"

module IsoDoc
  module JIS
    class Metadata < IsoDoc::Iso::Metadata
      def title(isoxml, _out)
        lang = case @lang
               when "ja", "en" then @lang
               else "ja"
               end
        # intro, main, part, amd = title_parts(isoxml, lang)
        tp = title_parts(isoxml, lang)
        tn = title_nums(isoxml)

        set(:doctitlemain,
            @c.encode(tp[:main] ? tp[:main].text : "", :hexadecimal))
        main = compose_title(tp, tn, lang)
        set(:doctitle, main)
        tp[:intro] and
          set(:doctitleintro,
              @c.encode(tp[:intro] ? tp[:intro].text : "", :hexadecimal))
        set(:doctitlepartlabel, part_prefix(tn, lang))
        set(:doctitlepart, @c.encode(tp[:part].text, :hexadecimal)) if tp[:part]
        set(:doctitleamdlabel, amd_prefix(tn, lang)) if tn[:amd]
        set(:doctitleamd, @c.encode(tp[:amd].text, :hexadecimal)) if tp[:amd]
        set(:doctitlecorrlabel, corr_prefix(tn, lang)) if tn[:corr]
      end

      def subtitle(isoxml, _out)
        lang = @lang == "ja" ? "en" : "ja"
        tp = title_parts(isoxml, lang)
        tn = title_nums(isoxml)

        set(:docsubtitlemain,
            @c.encode(tp[:main] ? tp[:main].text : "", :hexadecimal))
        main = compose_title(tp, tn, lang)
        set(:docsubtitle, main)
        tp[:intro] and
          set(:docsubtitleintro,
              @c.encode(tp[:intro] ? tp[:intro].text : "", :hexadecimal))
        set(:docsubtitlepartlabel, part_prefix(tn, lang))
        tp[:part] and
          set(:docsubtitlepart,
              @c.encode(tp[:part].text, :hexadecimal))
        set(:docsubtitleamdlabel, amd_prefix(tn, lang)) if tn[:amd]
        set(:docsubtitleamd, @c.encode(tp[:amd].text, :hexadecimal)) if tp[:amd]
        set(:docsubtitlecorrlabel, corr_prefix(tn, lang)) if tn[:corr]
      end

      PART_LABEL = { en: "Part", ja: "その" }.freeze
    end
  end
end
