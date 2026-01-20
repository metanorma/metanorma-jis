module IsoDoc
  module Jis
    class PresentationXMLConvert < IsoDoc::Iso::PresentationXMLConvert
      def table1(node)
        super
        cols = table_cols_count(node)
        ins = node.at(ns("./fmt-xref-label")) ||
          node.at(ns("./fmt-name"))
        thead = table_thead_pt(node, ins)
        table_unit_notes(node, thead, cols)
        table_dl_to_tfoot(node)
        table_content_to_tfoot(node)
      end

      def table_dl_to_tfoot(node)
        node.at(ns("./key")) or return
        tf = initial_tfoot_cell(node)
        node.xpath(ns("./key")).reverse_each do |x|
          tf.children.first.previous = x.remove
        end
      end

      def table_content_to_tfoot(node)
        node.at(ns("./note | ./fmt-source | ./example | " \
          "./fmt-footnote-container")) or return
        tf = final_tfoot_cell(node)
        %w(example note fmt-footnote-container
           fmt-source).each do |n|
          node.xpath(ns("./#{n}")).each do |x|
            tf.children.last.next = x.remove
          end
        end
      end

      # how many columns in the table?
      def table_col_count(table)
        cols = 0
        table&.at(ns(".//tr"))&.xpath(ns("./td | ./th"))&.each do |td|
          cols += (td["colspan"] ? td["colspan"].to_i : 1)
        end
        cols
      end

      # if there is already a full-row cell at the start of tfoot,
      # use that to move content into
      # else create a full-row cell at the start of tfoot
      def initial_tfoot_cell(node)
        colspan = table_col_count(node)
        empty_row = full_row(colspan, " ", border: true)
        node.at(ns("./tfoot/tr/td")) or
          node.at(ns("./tbody")).after("<tfoot>#{empty_row}</tfoot>").first
        tfoot_start = node.at(ns("./tfoot/tr/td"))
        tfoot_start["colspan"] != colspan.to_s and
          tfoot_start.parent.previous = empty_row
        node.at(ns("./tfoot/tr/td"))
      end

      def final_tfoot_cell(node)
        colspan = table_col_count(node)
        empty_row = full_row(colspan, " ", border: true)
        node.at(ns("./tfoot/tr[last()]/td")) or
          node.at(ns("./tbody")).after("<tfoot>#{empty_row}</tfoot>").first
        tfoot_start = node.at(ns("./tfoot/tr[last()]/td"))
        tfoot_start["colspan"] != colspan.to_s and
          tfoot_start.parent.next = empty_row
        node.at(ns("./tfoot/tr[last()]/td"))
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

      def table_unit_notes(node, thead, cols)
        unit_notes = node.xpath(ns(".//note[@type = 'units']"))
        unit_notes.empty? and return
        thead.children.first.previous = full_row(cols, unit_notes.remove.to_xml)
      end

      def full_row(cols, elem, border: false)
        b = border ? "" : " border='0'"
        <<~XML
          <tr #{add_id_text}><td #{add_id_text}#{b} colspan='#{cols}'>#{elem}</td></tr>
        XML
      end
    end
  end
end
