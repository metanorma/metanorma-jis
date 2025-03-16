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
            else parse(c1, s) end
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
        node.xpath(ns("./p[@class = 'ListTitle' or @class = 'dl']"))
          .each { |p| parse(p, out) }
        node.xpath(ns("./source")).each { |n| parse(n, out) }
        node.xpath(ns("./note")).each { |n| parse(n, out) }
        node.xpath(ns("./fmt-footnote-container/fmt-fn-body"))
          .each { |n| parse(n, out) }
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

      def table_note_cleanup(docxml)
        tn = ::IsoDoc::Function::Cleanup::TABLENOTE_CSS
        docxml.xpath("//table[dl or #{tn} or p[@class = 'dl']]").each do |t|
          tfoot = table_get_or_make_tfoot(t)
          insert_here = new_fullcolspan_row(t, tfoot)
          t.xpath("dl | p[@class = 'ListTitle'] | #{tn} | " \
                  "p[@class = 'dl']")
            .each do |d|
            d.parent = insert_here
          end
        end
      end

         # table name footnote is formatted like other footnotes, since table name
      # is a table row.
      def footnote_parse(node, out)
        return table_footnote_parse(node, out) if @in_table
        super
      end
    end
  end
end
