require_relative "init"
require "isodoc"
require_relative "presentation_section"
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

      def ol_depth(node)
        depth = node.ancestors("ol").size + 1
        depth == 1 and return :alphabet
        :arabic
      end

      def admits(elem)
        #elem.children.first.previous = @i18n.l10n("#{@i18n.admitted}: ")
        elem.xpath(ns(".//semx[@element = 'admitted']")).each do |t|
        t.previous = @i18n.l10n("#{@i18n.admitted}: ")
      end
      end

      def dl(docxml)
        super
        docxml.xpath(ns("//table//dl | //figure//dl")).each do |l|
          l.at(ns("./dl")) || l.at("./ancestor::xmlns:dl") and next
          dl_to_para(l)
        end
      end

      def dt_dd?(node)
        %w{dt dd}.include? node.name
      end

      def dl_to_para(node)
        ret = dl_to_para_name(node)
        ret += dl_to_para_terms(node)
        node.elements.reject { |n| %w(dt dd name fmt-name).include?(n.name) }
          .each do |x|
          ret += x.to_xml
        end
        dl_id_insert(node, ret)
      end

      def dl_id_insert(node, ret)
        a = node.replace(ret)
        p = a.at("./descendant-or-self::xmlns:p")
        node["id"] and p << "<bookmark id='#{node['id']}'/>"
        a.xpath("./descendant-or-self::*[@id = '']").each { |x| x.delete("id") }
      end

      def dl_to_para_name(node)
        e = node.at(ns("./fmt-name")) or return ""
        node.parent.parent["type"] == "participants" and return ""
        "<p class='ListTitle'>#{e.children.to_xml}</p>"
      end

      def dl_to_para_terms(node)
        ret = ""
        node.elements.select { |n| dt_dd?(n) }.each_slice(2) do |dt, dd|
          term = strip_para(dt)
          defn = strip_para(dd)
          bkmk = dd["id"] ? "<bookmark id='#{dd['id']}'/>" : ""
          ret += "<p class='dl' id='#{dt['id']}'>#{term}: #{bkmk}#{defn}</p>"
        end
        ret
      end

      def strip_para(node)
        node.children.to_xml.gsub(%r{</?p( [^>]*)?>}, "")
      end

      def table1(node)
        super
        cols = table_cols_count(node)
        ins = node.at(ns("./fmt-xref-label")) ||
          node.at(ns("./fmt-name"))
        thead = table_thead_pt(node, ins)
        table_unit_note(node, thead, cols)
      end

      def table_thead_pt(node, name)
        node.at(ns("./thead")) ||
          name&.after("<thead> </thead>")&.next ||
          node.elements.first.before("<thead> </thead>").previous
      end

      def table_cols_count(node)
        cols = 0
        node.at(ns(".//tr")).xpath(ns("./td | ./th")).each do |x|
          cols += x["colspan"]&.to_i || 1
        end
        cols
      end

      def table_unit_note(node, thead, cols)
        unit_note = node.at(ns(".//note[@type = 'units']")) or return
        thead.children.first.previous = full_row(cols, unit_note.remove.to_xml)
      end

      def full_row(cols, elem)
        "<tr><td border='0' colspan='#{cols}'>#{elem}</td></tr>"
      end

      # KILL
      def tablesource(elem)
        while elem&.next_element&.name == "source"
          elem << "; #{to_xml(elem.next_element.remove.children)}"
        end
        elem.children = l10n("#{@i18n.source}: #{to_xml(elem.children).strip}")
      end

      # TODO preserve original Semantic XML source
      def tablesource(elem)
      ret = [semx_fmt_dup(elem)]
      while elem&.next_element&.name == "source"
        ret << semx_fmt_dup(elem.next_element.remove)
      end
      s = ret.map { |x| to_xml(x) }.map(&:strip).join("; ")
      tablesource_label(elem, s)
    end

    def tablesource_label(elem, sources)
      elem.children = l10n("#{@i18n.source}: #{sources}")
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
        fns = footnote_collect((elem.xpath(ns(".//fn")) -
                              elem.xpath(ns("./name//fn")))) and
        elem << fns
      end

       def table_fn(elem)
      fns = footnote_collect(elem.xpath(ns(".//fn"))) and
        elem << fns
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
          label = l10n("#{@i18n.table_footnote} #{fn_label(fnote)}")
          "<sup>#{label}" \
            "<span class='fmt-label-delim'>)</span></sup>"
        end
      end

       def non_document_footnotes(docxml)
      table_fns = docxml.xpath(ns("//table//fn"))
      fig_fns = docxml.xpath(ns("//figure//fn")) -
        docxml.xpath(ns("//figure/name//fn"))
      table_fns + fig_fns
    end


      include Init
    end
  end
end
