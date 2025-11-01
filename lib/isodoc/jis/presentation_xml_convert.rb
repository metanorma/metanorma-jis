require_relative "init"
require "isodoc"
require_relative "presentation_section"
require_relative "presentation_list"
require_relative "presentation_table"
require_relative "../../relaton/render-jis/general"

module IsoDoc
  module Jis
    class PresentationXMLConvert < IsoDoc::Iso::PresentationXMLConvert
      def inline(docxml)
        super
        strong(docxml)
      end

      JPAN = "\\p{Hiragana}\\p{Katakana}\\p{Han}".freeze
      JPAN_BOLD = "<span style='font-family:\"MS Gothic\"'>".freeze

      def strong(docxml)
        docxml.xpath(ns("//strong")).each do |x|
          (x.children.size == 1 && x.children.first.text?) or next # too hard
          x.replace(strong1(x.text))
        end
      end

      def strong1(text)
        jpan = /^[#{JPAN}]/o.match?(text[0])
        ret = jpan ? JPAN_BOLD : "<strong>"
        text.chars.each do |n|
          new = /^[#{JPAN}]/o.match?(n)
          jpan && !new and ret += "</span><strong>"
          !jpan && new and ret += "</strong>#{JPAN_BOLD}"
          ret += n
          jpan = new
        end
        ret += /[#{JPAN}]/o.match?(text[-1]) ? "</span>" : "</strong>"
        ret
      end

      def admits(elem)
        elem.xpath(ns(".//semx[@element = 'admitted']")).each do |t|
          t.previous = @i18n.l10n("#{@i18n.admitted}: ")
        end
      end

      def strip_para(node)
        node.children.to_xml.gsub(%r{</?p( [^>]*)?>}, "")
      end

      def contains_para?(text)
        /\([^()]+\)|（[^（）].+）/.match?(text)
      end

      def source1_label(elem, sources, ancestor)
        elem.children = if ancestor == :table
                          l10n("#{@i18n.source}: #{esc sources}")
                        elsif contains_para?(sources)
                          l10n("[#{@i18n.source}: #{esc sources}]")
                        else
                          l10n("(#{@i18n.source}: #{esc sources})")
                        end
      end

      def bibdata_i18n(bibdata)
        super
        @lang == "ja" and date_translate(bibdata)
      end

      def date_translate(bibdata)
        bibdata.xpath(ns("./date")).each do |d|
          j = @i18n.japanese_date(d.text.strip)
          @autonumbering_style == :japanese and
            j.gsub!(/(\d+)/) do
              $1.to_i.localize(:ja).spellout
            end
          d.children = j
        end
      end

      def edition_translate(bibdata)
        x = bibdata.at(ns("./edition")) or return
        /^\d+$/.match?(x.text) or return
        @i18n.edition_ordinal or return
        num = x.text.to_i
        @autonumbering_style == :japanese and num = num.localize(:ja).spellout
        x.next =
          %(<edition language="#{@lang}" numberonly="true">#{num}</edition>)
        tag_translate(x, @lang, @i18n
          .populate("edition_ordinal", { "var1" => num }))
      end

      def convert1(xml, filename, dir)
        j = xml.at(ns("//metanorma-extension/presentation-metadata/" \
                      "autonumbering-style"))&.text
        j ||= "arabic"
        @autonumbering_style = j.to_sym
        @xrefs.autonumbering_style = j.to_sym
        super
      end

      def localized_strings(docxml)
        super
        a = docxml.at(ns("//localized-strings")) or return
        ret = (0..1000).map do |i|
          n = i.localize(:ja).spellout
          "<localized-string key='#{i}' language='ja'>#{n}</localized-string>"
        end.join("\n")
        a << ret
      end

      def figure_fn(elem)
        fnotes = elem.xpath(ns(".//fn")) - elem.xpath(ns("./name//fn")) -
          elem.xpath(ns("./fmt-name//fn"))
        ret = footnote_collect(fnotes)
        f = footnote_container(fnotes, ret) and elem << f
      end

      def table_fn(elem)
        fnotes = elem.xpath(ns(".//fn"))
        ret = footnote_collect(fnotes)
        f = footnote_container(fnotes, ret) and elem << f
      end

      def omit_docid_prefix(prefix)
        prefix.nil? || prefix.empty? and return true
        super || %w(JIS).include?(prefix)
      end

      def fn_ref_label(fnote)
        if fnote.ancestors("table, figure").empty? ||
            !fnote.ancestors("figure").empty? &&
                !fnote.ancestors("name, fmt-name").empty?
          "<sup>#{fn_label(fnote)}</sup>"
        else
          "<sup>#{fn_label(fnote)}" \
            "<span class='fmt-label-delim'>)</span></sup>"
        end
      end

      def fn_body_label(fnote)
        if fnote.ancestors("table, figure").empty? ||
            !fnote.ancestors("figure").empty? &&
                !fnote.ancestors("name, fmt-name").empty?
          "<sup>#{fn_label(fnote)}</sup>"
        else
          spc = %w(zh ja ko).include?(@lang) ? "" : " "
          "#{@i18n.table_footnote}#{spc}<sup>#{fn_label(fnote)}" \
            "<span class='fmt-label-delim'>)</span></sup>"
        end
      end

      def table_footnotes(docxml)
        docxml.xpath(ns("//table//fn"))
      end

      # if termsource xref has no SDO identifier, cite instead by full reference
      def anchor_linkend(node, linkend)
        node.name == "fmt-origin" && fmt_origin_cite_full?(node) and
          node["style"] ||= "short"
        super
      end

      def fmt_origin_cite_full?(elem)
        sem_xml_descendant?(elem) and return
        id = elem["bibitemid"] or return
        b = @bibitem_lookup[id] or return
        !b.at(ns(<<~XPATH))
          ./docidentifier[not(#{SKIP_DOCID} or @scope = 'biblio-tag' or @type = 'metanorma' or @type = 'metanorma-ordinal' or @type='title')]
        XPATH
      end

      def termsource_join_delim(_elem)
        @lang == "ja" ? "、" : "; "
      end

      def source_join_delim(_elem)
        @lang == "ja" ? "、" : "; "
      end

      def termsource_mod_text_delim(_elem)
        @lang == "ja" ? "，" : ", "
      end

      def termsource_modification(elem)
        elem.xpath(".//text()[normalize-space() = '']").each(&:remove)
        origin = elem.at(ns("./origin"))
        mod = elem.at(ns("./modification"))
        s = termsource_status(elem["status"])
        mod && elem["status"] == "modified" and s = @i18n.modified_detail
        s and origin.next = l10n(", #{s}", @lang, @script,
                                 { prev: origin.text })
        mod or return
        termsource_add_modification_text(mod)
      end

      def termsource_label(elem, sources)
        if contains_para?(sources)
          elem.replace(l10n("[#{@i18n.source}: #{esc sources}]"))
        else
          elem.replace(l10n("(#{@i18n.source}: #{esc sources})"))
        end
      end

      def bracketed_refs_processing(docxml); end

      def norm_ref_entry_code(_ordinal, idents, _ids, _standard, datefn, bib)
        delim = bib.at(ns("./language"))&.text == "ja" ? "&#x3000;" : "<esc>,</esc> "
        ret = (idents[:ordinal] || idents[:metanorma] || idents[:sdo]).to_s
        ret = esc(ret)
        (idents[:ordinal] || idents[:metanorma]) && idents[:sdo] and
          ret += "#{delim}#{esc idents[:sdo]}"
        ret += datefn
        ret.empty? and return ret
        idents[:sdo] and ret += delim
        ret.sub(delim, "").strip.empty? and return ""
        ret
      end

      def biblio_ref_entry_code(ordinal, ids, _id, _standard, datefn, bib)
        delim = bib.at(ns("./language"))&.text == "ja" ? "&#x3000;" : "<esc>,</esc> "
        ret = esc(ids[:ordinal]) || esc(ids[:metanorma]) || "[#{esc ordinal.to_s}]"
        if ids[:sdo] && !ids[:sdo].empty?
          ret = prefix_bracketed_ref(ret)
          ret += "#{esc ids[:sdo]}#{datefn}#{delim}"
        else
          ret = prefix_bracketed_ref("#{ret}#{datefn}")
        end
        ret
      end

      include Init
    end
  end
end
