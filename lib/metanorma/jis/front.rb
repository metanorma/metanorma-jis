require "pubid-jis"

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
        node.attr("docidentifier") || node.attr("docnumber") or
          @fatalerror << "No docnumber attribute supplied"
        if id = node.attr("docidentifier")
          xml.docidentifier id.sub(/^JIS /, ""), **attr_code(type: "JIS")
        else iso_id(node, xml)
        end
        xml.docnumber node.attr("docnumber")
      end

      def get_typeabbr(node, amd: false)
        amd || node.attr("amendment-number") and return :amd
        case doctype(node)
        when "technical-report" then :tr
        when "technical-specification" then :ts
        when "amendment" then :amd
        end
      end

      def iso_id(node, xml)
        (!@amd && node.attr("docnumber")) || (@amd && node.attr("updates")) or
          return
        params = iso_id_params(node)
        iso_id_out(xml, params, true)
      end

      def iso_id_params(node)
        params = iso_id_params_core(node)
        params2 = iso_id_params_add(node)
        if node.attr("updates")
          orig_id = Pubid::Jis::Identifier::Base.parse(node.attr("updates"))
          orig_id.edition ||= 1
        end
        iso_id_params_resolve(params, params2, node, orig_id)
      end

      def iso_id_params_core(node)
        pub = (node.attr("publisher") || "JIS").split(/[;,]/)
        ret = { number: node.attr("docnumber"),
                part: node.attr("partnumber"),
                series: node.attr("docseries"),
                language: node.attr("language") == "en" ? "E" : nil,
                type: get_typeabbr(node),
                publisher: pub[0],
                copublisher: pub[1..-1] }.compact
        ret[:copublisher].empty? and ret.delete(:copublisher)
        ret
      end

      def iso_id_params_add(node)
        { number: node.attr("amendment-number"),
          year: iso_id_year(node) }.compact
      end

      def iso_id_out(xml, params, _with_prf)
        id = iso_id_default(params).to_s
        xml.docidentifier id.strip.sub(/^JIS /, ""), type: "JIS"
      rescue StandardError => e
        clean_abort("Document identifier: #{e}", xml)
      end

      def iso_id_default(params)
        Pubid::Jis::Identifier.create(**params)
      end
    end
  end
end
