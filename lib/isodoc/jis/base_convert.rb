require "isodoc"
require "metanorma-iso"

module IsoDoc
  module JIS
    module BaseConvert
      def termnote_parse(node, out)
        name = node.at(ns("./name"))&.remove
        out.div **note_attrs(node) do |div|
          div.p do |p|
            if name
              p.span class: "note_label" do |s|
                name.children.each { |n| parse(n, s) }
              end
              p << termnote_delim
            end
            para_then_remainder(node.first_element_child, node, p, div)
          end
        end
      end

      def admonition_name_parse(_node, div, name)
        div.span class: "note_label" do |s|
          name.children.each { |n| parse(n, s) }
          s << " &#x2014; "
        end
      end

      def make_tr_attr(cell, row, totalrows, header, bordered)
        cell["border"] == "0" and bordered = false
        super
      end

      def annex(node, out)
        node["commentary"] = "true" and return commentary(node, out)
        amd?(isoxml) and @suppressheadingnumbers = @oldsuppressheadingnumbers
        page_break(out)
        out.div **attr_code(annex_attrs(node)) do |s|
          node.elements.each do |c1|
            if c1.name == "title" then annex_name(node, c1, s)
            else parse(c1, s) end
          end
        end
        amd?(isoxml) and @suppressheadingnumbers = true
      end

      def commentary(node, out)
        page_break(out)
        out.div **attr_code(annex_attrs(node)) do |s|
          node.elements.each do |c1|
            if c1.name == "title" then annex_name(node, c1, s)
            else parse(c1, s)
            end
          end
        end
      end

      def table_parse(node, out)
        cols = table_cols_count(node)
        name = node.at(ns("./name"))
        thead = table_thead_pt(node, name)
        table_name(name, thead, cols)
        super
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

      def full_row(cols, elem)
        "<tr><td border='0' colspan='#{cols}'>#{elem}</td></tr>"
      end

      def table_name(name, thead, cols)
        name or return
        thead.children.first.previous =
          full_row(cols, "<p class='TableTitle' style='text-align:center;'> " \
                         "#{name.remove.children.to_xml}</p>")
      end
    end
  end
end
