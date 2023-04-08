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
        e = node.at(ns("./name")) or return ""
        "<p class='ListTitle'>#{e.children.to_xml}</p>"
      end

      def dl_to_para_terms(node)
        ret = ""
        node.elements.select { |n| dt_dd?(n) }.each_slice(2) do |dt, dd|
          term = strip_para(dt)
          defn = strip_para(dd)
          bkmk = dd["id"] ? "<bookmark id='#{dd['id']}'/>" : ""
          ret += "<p id='#{dt['id']}'>#{term}: #{bkmk}#{defn}</p>"
        end
        ret
      end

      def strip_para(node)
        node.children.to_xml.gsub(%r{</?p( [^>]*)>}, "")
      end

      def table1(node)
        super
        cols = table_cols_count(node)
        name = node.at(ns("./name"))
        thead = node.at(ns("./thead")) || name.after("<thead> </thead>").next
        table_unit_note(node, thead, cols)
        table_name(name, thead, cols)
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
        lbl = @xrefs.anchor(elem["id"], :label)
        if t = elem.at(ns("./title"))
          t.children = "<strong>#{to_xml(t.children)}</strong>"
        end
        prefix_name(elem, "<br/>", lbl, "title")
      end

      def tablesource(elem)
        while elem&.next_element&.name == "source"
          elem << "; #{to_xml(elem.next_element.remove.children)}"
        end
        elem.children = l10n("#{@i18n.source}: #{to_xml(elem.children).strip}")
      end

      include Init
    end
  end
end
