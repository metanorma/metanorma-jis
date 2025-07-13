module IsoDoc
  module Jis
    class WordConvert < IsoDoc::Iso::WordConvert
      def table_title_parse(node, out); end

      def table_attrs(node)
        style = table_attrs_style(node, node["class"])
        klass = node.text.length > 4000 ? "MsoTableGridBig" : "MsoTableGrid"
        node["plain"] == "true" and klass = nil
        { id: node["id"], title: node["alt"],
          summary: node["summary"], width: node["width"],
          class: klass,
          style: style,
          border: 0, cellspacing: 0, cellpadding: 0 }
      end

      def table_attrs_style(node, _klass)
        style = node["style"]
        node["plain"] == "true" or style ||= "border-collapse:collapse;" \
                 "mso-table-anchor-horizontal:column;mso-table-overlap:never;" \
                 "border:none;mso-padding-alt: " \
                 "0cm 5.4pt 0cm 5.4pt;mso-border-insideh:none;" \
                 "mso-border-insidev:none;"
        style
      end

      def make_tr_attr_style(cell, row, rowmax, totalrows, opt)
        top = row.zero? ? "#{SW1} 1.5pt;" : "none;"
        bottom = "#{SW1} #{rowmax >= totalrows ? '1.5' : '1.0'}pt;"
        ret = <<~STYLE.delete("\n")
          border-top:#{top}mso-border-top-alt:#{top}
          border-left:#{bottom}mso-border-top-alt:#{bottom}
          border-right:#{bottom}mso-border-top-alt:#{bottom}
          border-bottom:#{bottom}mso-border-bottom-alt:#{bottom}
        STYLE
        opt[:bordered] or ret = ""
        pb = keep_rows_together(cell, rowmax, totalrows, opt) ? "avoid" : "auto"
        "#{ret}page-break-after:#{pb};"
      end

      def new_fullcolspan_row(table, tfoot)
        cols = 0 # how many columns in the table?
        table.at(".//tr").xpath("./td | ./th").each do |td|
          cols += (td["colspan"] ? td["colspan"].to_i : 1)
        end
        table["class"].nil? or # plain table
          style = "style='border-top:0pt;mso-border-top-alt:0pt;" \
                "border-bottom:#{SW1} 1.5pt;mso-border-bottom-alt:#{SW1} 1.5pt;" \
                "border-left:#{SW1} 1.5pt;mso-border-left-alt:#{SW1} 1.5pt;" \
                "border-right:#{SW1} 1.5pt;mso-border-right-alt:#{SW1} 1.5pt;'"
        tfoot.add_child("<tr><td colspan='#{cols}' #{style}/></tr>")
        tfoot.xpath(".//td").last
      end
    end
  end
end
