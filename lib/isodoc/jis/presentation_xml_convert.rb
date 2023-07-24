require_relative "init"
require "isodoc"

module IsoDoc
  module JIS
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
        depth == 1 and return :alphabetic
        :arabic
      end

      def admits(elem)
        elem.children.first.previous = @i18n.l10n("#{@i18n.admitted}: ")
      end

      def block(docxml)
        super
        dl docxml
      end

      def dl(docxml)
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
        node.elements.reject { |n| %w(dt dd name).include?(n.name) }.each do |x|
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
        e = node.at(ns("./name"))
        "<p class='ListTitle'>#{e&.children&.to_xml || @i18n.key}</p>"
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
        name = node.at(ns("./name"))
        thead = table_thead_pt(node, name)
        table_unit_note(node, thead, cols)
        table_name(name, thead, cols)
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

      def table_name(name, thead, cols)
        name or return
        thead.children.first.previous =
          full_row(cols, "<p class='TableTitle' style='text-align:center;'> " \
                         "#{name.remove.children.to_xml}</p>")
      end

      def full_row(cols, elem)
        "<tr><td border='0' colspan='#{cols}'>#{elem}</td></tr>"
      end

      def annex1(elem)
        elem["commentary"] == "true" and return
        lbl = @xrefs.anchor(elem["id"], :label)
        if t = elem.at(ns("./title"))
          t.children = "<strong>#{to_xml(t.children)}</strong>"
        end
        prefix_name(elem, "<br/>", lbl, "title")
      end

      def annex(docxml)
        super
        move_commentaries_to_end(docxml)
      end

      def move_commentaries_to_end(docxml)
        docxml.at(ns("//annex[@commentary = 'true']")) or return
        b = docxml.at(ns("//bibliography")) ||
          docxml.at(ns("//annex[last()]")).after(" ").next
        docxml.xpath(ns("//annex[@commentary = 'true']")).reverse.each do |x|
          b.next = x.remove
        end
      end

      def display_order(docxml)
        i = 0
        i = display_order_xpath(docxml, "//preface/*", i)
        i = display_order_at(docxml, "//sections/introduction", i)
        i = display_order_at(docxml, "//clause[@type = 'scope']", i)
        i = display_order_at(docxml, @xrefs.klass.norm_ref_xpath, i)
        i = display_order_at(docxml, "//sections/terms | " \
                                     "//sections/clause[descendant::terms]", i)
        i = display_order_at(docxml, "//sections/definitions", i)
        i = display_order_xpath(docxml, @xrefs.klass.middle_clause(docxml), i)
        i = display_order_xpath(docxml, "//annex[not(@commentary = 'true')]", i)
        i = display_order_xpath(docxml, @xrefs.klass.bibliography_xpath, i)
        i = display_order_xpath(docxml, "//annex[@commentary = 'true']", i)
        i = display_order_xpath(docxml, "//indexsect", i)
        display_order_xpath(docxml, "//colophon/*", i)
      end

      def tablesource(elem)
        while elem&.next_element&.name == "source"
          elem << "; #{to_xml(elem.next_element.remove.children)}"
        end
        elem.children = l10n("#{@i18n.source}: #{to_xml(elem.children).strip}")
      end

      def toc_title_insert_pt(docxml)
        ins = docxml.at(ns("//preface")) ||
          docxml.at(ns("//sections | //annex | //bibliography"))
            &.before("<preface> </preface>")
            &.previous_element or return nil
        ins.children.last.after(" ").next
      end

      def preface_rearrange(doc)
        move_introduction(doc)
        super
      end

      def move_introduction(doc)
        source = doc.at(ns("//preface/introduction")) or return
        dest = doc.at(ns("//sections")) ||
          doc.at(ns("//preface")).after("<sections> </sections>").next_element
        dest.children.empty? and dest.children = " "
        dest.children.first.next = source
      end

      def middle_title(docxml)
        s = docxml.at(ns("//sections")) or return
        middle_title_hdr(s.children.first)
        middle_title_main(s.children.first, "zzSTDTitle1")
        middle_subtitle_main(s.children.first)
        # middle_title_amd(s.children.first)
      end

      def middle_title_hdr(out)
        ret = "<p class='JapaneseIndustrialStandard'>#{@i18n.jis}"
        @meta.get[:unpublished] and ret += @i18n.l10n("(#{@i18n.draft_label})")
        ret += ("<tab/>" * 7)
        ret += "<span class='JIS'>JIS</span></p>"
        ret += "<p class='StandardNumber'><tab/>#{@meta.get[:docnumber_undated]}"
        if yr = @meta.get[:docyear]
          ret += ": <span class='EffectiveYear'>#{yr}</span>"
        end
        ret += "</p><p class='IDT'/>"
        out.previous = ret
      end

      def middle_title_main(out, style)
        ret = "<p class='#{style}'>#{@meta.get[:doctitleintro]}"
        ret += " &#x2014; " if @meta.get[:doctitleintro] && @meta.get[:doctitlemain]
        ret += @meta.get[:doctitlemain]
        ret += " &#x2014; " if @meta.get[:doctitlemain] && @meta.get[:doctitlepart]
        ret += "</p>"
        if a = @meta.get[:doctitlepart]
          ret += "<p class='zzSTDTitle1'>"
          b = @meta.get[:doctitlepartlabel] and ret += "#{b}: "
          ret += "<br/><strong>#{a}</strong></p>"
        end
        out.previous = ret
      end

      def middle_subtitle_main(out)
        @meta.get[:docsubtitlemain] or return
        ret = "<p class='zzSTDTitle2'>#{@meta.get[:docsubtitleintro]}"
        ret += " &#x2014; " if @meta.get[:docsubtitleintro] && @meta.get[:docsubtitlemain]
        ret += @meta.get[:docsubtitlemain]
        ret += " &#x2014; " if @meta.get[:docsubtitlemain] && @meta.get[:docsubtitlepart]
        ret += "</p>"
        if a = @meta.get[:docsubtitlepart]
          ret += "<p class='zzSTDTitle2'>"
          b = @meta.get[:docsubtitlepartlabel] and ret += "#{b}: "
          ret += "<br/><strong>#{a}</strong></p>"
        end
        out.previous = ret
      end

      include Init
    end
  end
end
