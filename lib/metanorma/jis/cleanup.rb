module Metanorma
  module Jis
    class Cleanup < Iso::Cleanup
      def boilerplate_file(_x_orig)
        File.join(@libdir, "boilerplate-#{@lang}.adoc")
      end

      def norm_ref_preface(ref, isodoc)
        if ref.at("./note[@type = 'boilerplate']")
          unwrap_boilerplate_clauses(ref, ".")
        else
          pref = if ref_empty?(ref) then @i18n.norm_empty_pref
                 else @i18n.get[ref_dated(ref)]
                 end
          ref.at("./title").next = boilerplate_snippet_convert(pref, isodoc)
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
        ::Metanorma::Standoc::Cleanup.instance_method(:ol_cleanup).bind(self)
          .call(doc)
      end

      def biblio_reorder(xmldoc)
        xmldoc.xpath("//references[@normative = 'true']").each do |r|
          biblio_reorder1(r)
        end
      end

      # JIS first, then ISO, then IEC, then other standards, then everything
      # else. A co-publisher is ordered by the secondary key (see
      # Standoc::Ref#publisher_sort_second), which reproduces the historical
      # JIS ordering: JIS+IEC before JIS+ISO, JIS+IEC+ISO alongside JIS+IEC.
      # Built at runtime because the JIS publisher name is language-dependent
      # (@conv.pub_hash). Overridable per-document / per-taste via
      # :sort-biblio-<abbrev>:.
      def default_publisher_sort
        [
          { abbrev: "JIS",
            name: [@conv.pub_hash["ja"], @conv.pub_hash["en"]].compact,
            rank: 1 },
          { abbrev: "ISO",
            name: "International Organization for Standardization", rank: 2 },
          { abbrev: "IEC", name: "International Electrotechnical Commission",
            rank: 3 },
        ]
      end

      def pub_class(bib)
        publisher_sort_rank(bib, default_publisher_sort)
      end

      def second_pub_class(bib, _first_pub = nil)
        publisher_sort_second(bib, default_publisher_sort)
      end
    end
  end
end
