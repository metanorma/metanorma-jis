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
        text.split("").each do |n|
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
        ret = ""
        e = node.at(ns("./name")) and
          ret += "<p class='ListTitle' id='#{dlist['id']}'>" \
                 "#{e.children.to_xml}</p>"
        node.elements.select { |n| dt_dd?(n) }.each_slice(2) do |dt, dd|
          term = dt.children.to_xml.gsub(%r{</?p( [^>]*)>}, "")
          defn = dd.children.to_xml.gsub(%r{</?p( [^>]*)>}, "")
          ret += "<p id='#{dt['id']}'>#{term}: " \
                 "<bookmark id='#{dd['id']}'/>#{defn}</p>"
        end
        node.elements.each do |x|
          %w(dt dd name).include?(x.name) and next
          ret += x.to_xml
        end
        node.replace(ret.gsub(/ id=''/, ""))
      end

      def table1(node)
        super
        cols = 0
        node.at(ns(".//tr")).xpath(ns("./td | ./th")).each do |x|
          cols += x["colspan"]&.to_i || 1
        end
        name = node.at(ns("./name"))
        h = node.at(ns("./thead")) || name.after("<thead> </thead>").next
        unit_note = node.at(ns(".//note[@type = 'units']"))&.remove
        unit_note and h.children.first.previous = full_row(cols,
                                                           unit_row.to_xml)
        name and h.children.first.previous =
          full_row(cols,
                   "<p class='TableTitle' style='text-align:center;'>#{name.remove.children.to_xml}</p>")
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

      include Init
    end
  end
end
