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
          t.xpath(".//fn").each do |fn|
            i, seen = table_footnote_renumber1(fn, i, seen)
          end
        end
      end

      def docidentifier_cleanup(xmldoc); end

      def note_cleanup(xmldoc)
        note_example_to_table(xmldoc)
        super
        clean_example_keep_separate(xmldoc)
      end

      def note_example_to_table(xmldoc)
        xmldoc.xpath("//table").each do |t|
          t.xpath("./following-sibling::*").each do |n|
            %w(note example).include?(n.name) or break
            n["keep-separate"] == "true" and break
            n.parent = t
          end
        end
      end

      def clean_example_keep_separate(xmldoc)
        xmldoc.xpath("//example[@keep-separate] | " \
                     "//termexample[@keep-separate]").each do |n|
          n.delete("keep-separate")
        end
      end

      def bibdata_cleanup(xmldoc)
        super
        bibdata_supply_chairperson_role(xmldoc)
      end

      def bibdata_supply_chairperson_role(xmldoc)
        xpath =
          "//bibdata/contributor" \
          "[role/@type = 'authorizer'][role/description = " \
          "'investigative committee']/person/affiliation"
        xmldoc.xpath(xpath).each do |a|
          a.at("./name") or next
          a.children.first.previous = "<name>#{@i18n.chairperson}</name>"
        end
      end

      def ol_cleanup(doc)
        ::Metanorma::Standoc::Converter.instance_method(:ol_cleanup).bind(self)
          .call(doc)
      end
    end
  end
end
