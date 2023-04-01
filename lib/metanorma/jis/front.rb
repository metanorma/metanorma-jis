module Metanorma
  module JIS
    class Converter < ISO::Converter
      def org_abbrev
        super.merge("Japanese Industrial Standards" => "JIS")
      end

      def metadata_author(node, xml)
        publishers = node.attr("publisher") || "JIS"
        csv_split(publishers)&.each do |p|
          xml.contributor do |c|
            c.role type: "author"
            c.organization do |a|
              organization(a, p, false, node, !node.attr("publisher"))
            end
          end
        end
        node.attr("doctype") == "expert-commentary" and
          personal_author(node, xml)
      end

      def metadata_publisher(node, xml)
        publishers = node.attr("publisher") || "JIS"
        csv_split(publishers)&.each do |p|
          xml.contributor do |c|
            c.role type: "publisher"
            c.organization do |a|
              organization(a, p, true, node, !node.attr("publisher"))
            end
          end
        end
      end

      def metadata_copyright(node, xml)
        pub = node.attr("copyright-holder") || node.attr("publisher") || "JIS"
        csv_split(pub)&.each do |p|
          xml.copyright do |c|
            c.from (node.attr("copyright-year") || Date.today.year)
            c.owner do |owner|
              owner.organization do |o|
                organization(o, p, true, node,
                             !node.attr("copyright-holder") ||
                             node.attr("publisher"))
              end
            end
          end
        end
      end

      def title(node, xml)
        %w(en ja).each do |lang|
          at = { language: lang, format: "text/plain" }
          title_full(node, xml, lang, at)
          title_intro(node, xml, lang, at)
          title_main(node, xml, lang, at)
          title_part(node, xml, lang, at)
          title_amd(node, xml, lang, at) if @amd
        end
      end

      def metadata_id(node, xml)
        if id = node.attr("docidentifier")
          xml.docidentifier id.sub(/^JIS /, ""), **attr_code(type: "JIS")
        else iso_id(node, xml)
        end
        xml.docnumber node.attr("docnumber")
      end

      def iso_id(node, xml)
        id = case doctype(node)
             when "japanese-industrial-standard", "amendment" then ""
             when "technical-report" then "TR"
             when "technical-specification" then "TS"
             else ""
             end
        a = node.attr("docseries") and id += " #{a}"
        a = node.attr("docnumber") and id += " #{a}"
        yr = iso_id_year(node)
        origyr = node.attr("created-date")&.sub(/-.*$/, "") || yr
        a = node.attr("amendment-number") and
          id += ":#{origyr}/AMD #{a}"
        id += ":#{yr}"
        xml.docidentifier id.strip, type: "JIS"
      end
    end
  end
end
