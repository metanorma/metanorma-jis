require "pubid-jis"

module Metanorma
  module JIS
    class Converter < ISO::Converter
      def org_abbrev
        super.merge("Japanese Industrial Standards" => "JIS")
      end

      def default_publisher
        "JIS"
      end

      def metadata_author(node, xml)
        org_contributor(node, xml,
                        { source: ["publisher", "pub"], role: "author",
                          default: JIS_HASH })
        personal_author(node, xml)
      end

      def metadata_publisher(node, xml)
        [{ source: ["publisher", "pub"], role: "publisher", default: JIS_HASH },
         { role: "authorizer",
           source: ["investigative-organization"],
           desc: "Investigative organization" },
         { role: "authorizer",
           source: ["investigative-committee"],
           desc: "Investigative committee" }].each do |o|
          org_contributor(node, xml, o)
        end
      end

      LANGS = %w(ja en).freeze

      JIS_HASH =
        { "ja" => "日本工業規格", "en" => "Japanese Industrial Standards" }.freeze

      def org_organization(node, xml, org)
        organization(xml, { name: org[:name], abbr: org[:abbr] }.compact,
                     node, !multiling_docattr(node, "publisher", "", LANGS))
        org_address(org, xml)
        org_logo(xml, org[:logo])
      end

      def org_attrs_parse(node, opts)
        source = opts[:source]&.detect { |s| node.attr(s) }
        source ||= opts[:source]&.detect do |s|
          LANGS.detect { |l| node.attr("#{s}-#{l}") }
        end
        org_attrs_simple_parse(node, opts, source) ||
          org_attrs_complex_parse(node, opts, source)
      end

      def org_attrs_complex_parse(node, opts, source)
        i = 1
        suffix = ""
        ret = []
        while multiling_docattr(node, source, suffix, LANGS)
          ret << extract_org_attrs_complex(node, opts, source, suffix)
          i += 1
          suffix = "_#{i}"
        end
        ret
      end

      def multiling_docattr(node, attr, suffix, langs)
        node.nil? and return nil
        ret = node.attr(attr + suffix) and return ret
        ret = langs.each_with_object({}).each do |l, m|
          x = node.attr("#{attr}-#{l}#{suffix}") and m[l] = x
        end
        ret.empty? and return nil
        compact_blank(ret)
      end

      def extract_org_attrs_complex(node, opts, source, suffix)
        compact_blank({ name: multiling_docattr(node, source, suffix, LANGS),
                        role: opts[:role], desc: opts[:desc],
                        abbr: multiling_docattr(node, "#{source}-abbr", suffix, LANGS),
                        logo: multiling_docattr(node, "#{source}_logo", suffix, LANGS) })
          .merge(extract_org_attrs_address(node, opts, suffix))
      end

      def extract_org_attrs_address(node, opts, suffix)
        %w(address phone fax email uri).each_with_object({}) do |a, m|
          opts[:source]&.each do |s|
            p = multiling_docattr(node, "#{s}-#{a}", suffix, LANGS) and
              m[a.to_sym] = p
          end
        end
      end

      def multiling_noko_value(value, tag, xml)
        if value.is_a?(Hash)
          value.each do |k, v|
            xml.send tag, language: k do |x|
              x << v
            end
          end
        elsif value.is_a?(Array)
          value.each { |a| xml.send tag, a }
        else xml.send tag, value
        end
      end

      def organization(xml, org, node = nil, default_org = nil)
        org.is_a?(Hash) && org[:name] or org = { name: org }
        abbrevs = org_abbrev
        name_str = org[:name].is_a?(Hash) ? org[:name]["en"] : org[:name]
        n = abbrevs.invert[org[:name]] and org = { name: n, abbr: org[:name] }
        multiling_noko_value(org[:name], "name", xml)
        default_org && a = multiling_docattr(node, "subdivision", "", LANGS) and
          multiling_noko_value(a, "subdivision", xml)
        abbr = org[:abbr]
        abbr ||= org_abbrev[name_str]
        default_org && b = node&.attr("subdivision-abbr") and abbr = b
        abbr and xml.abbreviation abbr
      end

      def copyright_parse(node)
        opt = { source: ["copyright-holder", "publisher", "pub"],
                role: "publisher", default: JIS_HASH }
        ret = org_attrs_parse(node, opt)
        ret.empty? and ret = [{ name: "-" }]
        ret
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
          xml.docidentifier id.sub(/^JIS /, ""),
                            **attr_code(type: "JIS", primary: "true")
        else iso_id(node, xml)
        end
      end

      def get_typeabbr(node, amd: false)
        amd || node.attr("amendment-number") and return :amd
        case doctype(node)
        when "technical-report" then :tr
        when "technical-specification" then :ts
        when "amendment" then :amd
        end
      end

      def base_pubid
        Pubid::Jis::Identifier
      end

      def iso_id_params_core(node)
        pub = iso_id_pub(node)
        ret = { number: node.attr("docnumber") || "0",
                part: node.attr("partnumber"),
                series: node.attr("docseries"),
                language: node.attr("language") == "en" ? "E" : nil,
                type: get_typeabbr(node),
                publisher: pub[0],
                copublisher: pub[1..-1] }.compact
        ret[:copublisher].empty? and ret.delete(:copublisher)
        compact_blank(ret)
      end

      def iso_id_params_add(node)
        ret = { number: node.attr("amendment-number"),
                year: iso_id_year(node) }
        compact_blank(ret)
      end

      def iso_id_out(xml, params, _with_prf)
        id = iso_id_default(params).to_s(with_publisher: false)
        xml.docidentifier id.strip, type: "JIS", primary: "true"
      end

      def iso_id_default(params)
        base_pubid.create(**params)
      rescue StandardError => e
        clean_abort("Document identifier: #{e}", xml)
      end
    end
  end
end
