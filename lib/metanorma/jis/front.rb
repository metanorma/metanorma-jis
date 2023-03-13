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
    end
  end
end
