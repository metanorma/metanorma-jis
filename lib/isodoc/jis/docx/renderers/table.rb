# frozen_string_literal: true

module IsoDoc
  module Jis
    module Docx
      module Renderers
        # Renders a TableBlock as a full OOXML <w:tbl> via Uniword's
        # TableBuilder. Uses the template's table styles for header cells
        # and body cells.
        class TableRenderer
          include Base

          def render(node)
            table = Uniword::Builder::TableBuilder.new
            table.width = "5000"
            render_rows(table, node)
            doc << table
          end

          private

          def render_rows(table, node)
            (thead_rows(node) + tbody_rows(node)).each_with_index do |row, i|
              table_row = build_row(row, header: i < thead_rows(node).size)
              table.row(table_row)
            end
          end

          def build_row(row, header:)
            row_builder = Uniword::Builder::TableRowBuilder.new
            cells(row).each do |cell|
              row_builder.cell(build_cell(cell, header: header))
            end
            row_builder
          end

          def build_cell(cell, header:)
            cell_builder = Uniword::Builder::TableCellBuilder.new
            render_cell_paragraph(cell, cell_builder, header: header)
            cell_builder
          end

          def render_cell_paragraph(cell, cell_builder, header:)
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = header ? header_style_id : body_style_id
            run = Uniword::Builder::RunBuilder.new
            run.text(cell_text(cell))
            para << run
            cell_builder << para
          end

          def cell_text(cell)
            cell.respond_to?(:text) ? Array(cell.text).join : cell.to_s
          end

          def thead_rows(node) = Array(node.thead&.tr)
          def tbody_rows(node) = Array(node.tbody&.tr)
          def cells(row) = Array(row.td) + Array(row.th)
          def header_style_id = resolver.lookup(:table_header) || "a"
          def body_style_id = resolver.lookup(:table_body) || "a"
        end
      end
    end
  end
end
