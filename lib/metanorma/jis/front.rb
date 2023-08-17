require "pubid-jis"

module Metanorma
  module JIS
    class Converter < ISO::Converter
      def org_abbrev
        super.merge("Japanese Industrial Standards" => "JIS")
      end

      def home_agency
        "JIS"
      end

      # Like the ISO code, but multilingual
      def metadata_author(node, xml)
        metadata_contrib_sdo(node, xml, JIS_HASH,
                             { role: "author", sourcerole: "publisher" })
        node.attr("doctype") == "expert-commentary" and
          personal_author(node, xml)
      end

      def metadata_publisher(node, xml)
        metadata_contrib_sdo(node, xml, JIS_HASH,
                             { role: "publisher", sourcerole: "publisher" })
        metadata_contrib_sdo(node, xml, nil,
                             { role: "authorizer",
                               sourcerole: "investigative-organization",
                               desc: "Investigative organization" })
        metadata_contrib_sdo(node, xml, nil,
                             { role: "authorizer",
                               sourcerole: "investigative-committee",
                               desc: "Investigative committee" })
      end

      LANGS = %w(ja en).freeze

      JIS_HASH =
        { "ja" => "日本工業規格", "en" => "Japanese Industrial Standards" }.freeze

      def metadata_contrib_sdo(node, xml, default_value, opt)
        pub, default = metadata_contrib_extract(node, opt[:sourcerole], default_value)
        metadata_contrib_sdo_build(node, xml, pub, default, opt)
      end

      def metadata_contrib_sdo_build(node, xml, pub, default, opt)
        pub&.each do |p|
          xml.contributor do |c|
            c.role type: opt[:role] do |r|
              opt[:desc] and r.description opt[:desc]
            end
            c.organization do |a|
              organization(a, p, opt[:role] == "publisher", node, default)
            end
          end
        end
      end

      def metadata_contrib_extract(node, role, default_value)
        pub, default = multiling_docattr_csv(node, role, LANGS, default_value)
        a = node.attr("#{role}-abbr") and abbr = a # one abbrev for all languages
        [pub&.map { |p| { name: p, abbr: abbr } }, default]
      end

      def multiling_docattr(node, attr, langs)
        ret = node.attr(attr) and return ret
        ret = langs.each_with_object({}).each do |l, m|
          x = node.attr("#{attr}-#{l}") and m[l] = x
        end.compact
        ret.empty? and return nil
        ret
      end

      def multiling_docattr_csv(node, attr, langs, default)
        ret = multiling_docattr(node, attr, langs)
        not_found = ret.nil?
        ret ||= default
        ret &&= if ret.is_a?(Hash) then interleave_multiling_docattr(ret)
                else csv_split(ret)
                end
        [ret, not_found]
      end

      # TODO abort if CSV count different between different languages
      def interleave_multiling_docattr(ret)
        h = ret.transform_values { |v| csv_split(v) }
        h.each_with_object([]) do |(k, v), m|
          v.each_with_index do |v1, i|
            m[i] ||= {}
            m[i][k] = v1
          end
        end
      end

      def multiling_noko_value(value, tag, xml)
        if value.is_a?(Hash)
          xml.send tag do |t|
            value.each do |k, v|
              t.variant v, language: k
            end
          end
        elsif value.is_a?(Array)
          value.each { |a| xml.send tag, a }
        else xml.send tag, value
        end
      end

      def organization(xml, org, _is_pub, node = nil, default_org = nil)
        org.is_a?(Hash) or org = { name: org }
        abbrevs = org_abbrev
        name_str = org[:name].is_a?(Hash) ? org[:name]["en"] : org[:name]
        n = abbrevs.invert[org[:name]] and org = { name: n, abbr: org[:name] }
        multiling_noko_value(org[:name], "name", xml)
        default_org && a = multiling_docattr(node, "subdivision", LANGS) and
          multiling_noko_value(a, "subdivision", xml)
        abbr = org[:abbr]
        abbr ||= org_abbrev[name_str]
        default_org && b = node.attr("subdivision-abbr") and abbr = b
        abbr and xml.abbreviation abbr
        # is_pub && node and org_address(node, org) # should refactor into struct, like abbr
      end

      def metadata_copyright(node, xml)
        pub, default = metadata_contrib_extract(node, "copyright-holder", nil)
        if default
          pub, default = metadata_contrib_extract(node, "publisher", JIS_HASH)
        end

        pub&.each do |p|
          xml.copyright do |c|
            c.from (node.attr("copyright-year") || Date.today.year)
            c.owner do |owner|
              owner.organization do |o|
                organization(o, p, true, node, default)
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
        ret = { number: node.attr("docnumber") || "0",
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
        id = iso_id_default(params).to_s(with_publisher: false)
        xml.docidentifier id.strip, type: "JIS"
      end

      def iso_id_default(params)
        Pubid::Jis::Identifier.create(**params)
      rescue StandardError => e
        clean_abort("Document identifier: #{e}", xml)
      end
    end
  end
end
