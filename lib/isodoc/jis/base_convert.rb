require "isodoc"
require "metanorma-iso"

module IsoDoc
  module Jis
    module BaseConvert
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
            if c1.name == "fmt-title" then annex_name(node, c1, s)
            else parse(c1, s)
            end
          end
        end
        amd?(isoxml) and @suppressheadingnumbers = true
      end

      def commentary(node, out)
        page_break(out)
        out.div **attr_code(annex_attrs(node)) do |s|
          node.elements.each do |c1|
            if c1.name == "fmt-title" then annex_name(node, c1, s)
            else parse(c1, s)
            end
          end
        end
      end

      def table_parse(node, out)
        cols = table_cols_count(node)
        name = node.at(ns("./fmt-name"))
        thead = table_thead_pt(node, name)
        table_name(name, thead, cols)
        super
      end

      def table_parse_tail(node, out)
        table_parse_tail?(node) or return
        tfoot = table_get_or_make_tfoot(out.parent)
        [["./key", "./fmt-source", "./note"],
         ["./fmt-footnote-container/fmt-fn-body"]].each do |e|
          e.any? { |x| node.at(ns(x)) } or next
          ins = new_fullcolspan_row(out.parent, tfoot)
          b = Nokogiri::XML::Builder.with(ins)
          e.each do |k|
            node.xpath(ns(k)).each { |n| parse(n, b) }
          end
        end
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
        thead.add_first_child full_row(
          cols, "<fmt-name><p class='TableTitle' style='text-align:center;'> " \
                "#{name.remove.children.to_xml}</p></fmt-name>"
        )
      end

      # table name footnote is formatted like other footnotes, since table name
      # is a table row.
      def footnote_parse(node, out)
        @in_table and return table_footnote_parse(node, out)
        super
      end
    end
  end
end
