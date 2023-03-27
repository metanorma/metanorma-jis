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
    end
  end
end
