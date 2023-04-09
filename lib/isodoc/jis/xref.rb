module IsoDoc
  module JIS
    class Counter < IsoDoc::XrefGen::Counter
    end

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
          i = Counter.new("@")
          xml.xpath(ns("//annex")).each do |c|
            if c["commentary"] == "true"
              commentary_names(c)
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

      def commentary_names(clause)
        preface_name_anchors(clause, 1, clause_title(clause))
        clause.xpath(ns(SUBCLAUSES)).each_with_object(Counter.new) do |c, i|
          commentary_names1(c, clause["id"], i.increment(c).print, 2)
        end
      end

      def commentary_names1(clause, root, num, level)
        commentary_name_anchors(clause, num, root, level)
        clause.xpath(ns(SUBCLAUSES)).each_with_object(Counter.new) do |c, i|
          commentary_names1(c, root, "#{num}.#{i.increment(c).print}",
                            level + 1)
        end
      end

      def commentary_name_anchors(clause, num, root, level)
        @anchors[clause["id"]] =
          { label: num, xref: l10n("#{@labels['clause']} #{num}"),
            container: root,
            title: clause_title(clause), level: level, type: "clause",
            elem: @labels["clause"] }
      end
    end
  end
end
