module IsoDoc
  module JIS
    class Xref < IsoDoc::Iso::Xref
      def annex_name_lbl(clause, num)
        obl = l10n("(#{@labels['inform_annex']})")
        clause["obligation"] == "normative" and
          obl = l10n("(#{@labels['norm_annex']})")
        title = Common::case_with_markup(@labels["annex"], "capital", @script)
        l10n("#{title} #{num}<br/>#{obl}")
      end

      def back_anchor_names(xml)
        if @parse_settings.empty? || @parse_settings[:clauses]
          i = ::IsoDoc::XrefGen::Counter.new("@")
          xml.xpath(ns("//annex")).each do |c|
            if c["commentary"] == "true"
              preface_names(c)
            else
              annex_names(c, i.increment(c).print)
            end
          end
          xml.xpath(ns(@klass.bibliography_xpath)).each do |b|
            preface_names(b)
          end
          xml.xpath(ns("//colophon/clause")).each { |b| preface_names(b) }
          xml.xpath(ns("//indexsect")).each { |b| preface_names(b) }
        end
        references(xml) if @parse_settings.empty? || @parse_settings[:refs]
      end
    end
  end
end
