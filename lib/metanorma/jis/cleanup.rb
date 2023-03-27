module Metanorma
  module JIS
    class Converter < ISO::Converter
      def norm_ref_preface(ref)
        if ref.at("./note[@type = 'boilerplate']")
          unwrap_boilerplate_clauses(ref, ".")
        else
          pref = if ref_empty?(ref) then @i18n.norm_empty_pref
                 else @i18n.get[ref_dated(ref)]
                 end
          ref.at("./title").next = "<p>#{pref}</p>"
        end
      end

      def ref_empty?(ref)
        ref.xpath(".//bibitem").empty?
      end

      def ref_dated(ref)
        refs = ref.xpath("./bibitem").each_with_object({}) do |e, m|
          if e.at("./date") then m[:dated] = true
          else m[:undated] = true
          end
        end
        refs[:dated] && refs[:undated] and return "norm_with_refs_pref"
        refs[:dated] and return "norm_with_refs_pref_all_dated"
        "norm_with_refs_pref_none_dated"
      end

      def table_footnote_renumber(xmldoc)
        xmldoc.xpath("//table | //figure").each do |t|
          seen = {}
          i = 0
          #t.xpath(".//fn[not(ancestor::name)]").each do |fn|
          t.xpath(".//fn").each do |fn|
            i, seen = table_footnote_renumber1(fn, i, seen)
          end
        end
      end
    end
  end
end
