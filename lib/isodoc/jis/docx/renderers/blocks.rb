# frozen_string_literal: true

module IsoDoc
  module Jis
    module Docx
      module Renderers
        # Block renderers for note, example, admonition, figure, formula,
        # sourcecode, quote, definition list, page break, horizontal rule.
        # Each one wraps content with the JIS style for that block type.

        class NoteRenderer
          include Base
          def render(node)
            para = build_paragraph("注記　#{text_of(node)}", style: note_style_id)
            doc << para
          end
          def note_style_id = resolver.lookup(:note) || "af"
          def text_of(node)
            Array(node.paragraphs).map { |p| Array(p.text).join }.join
          end
        end

        class ExampleRenderer
          include Base
          def render(node)
            para = build_paragraph("例　#{text_of(node)}", style: example_style_id)
            doc << para
          end
          def example_style_id = resolver.lookup(:example) || "af"
          def text_of(node)
            Array(node.paragraphs).map { |p| Array(p.text).join }.join
          end
        end

        class AdmonitionRenderer
          include Base
          def render(node)
            label = node.type ? "#{node.type.upcase}　" : ""
            para = build_paragraph("#{label}#{text_of(node)}",
                                   style: admonition_style_id)
            doc << para
          end
          def admonition_style_id = resolver.lookup(:admonition) || "af"
          def text_of(node)
            Array(node.paragraphs).map { |p| Array(p.text).join }.join
          end
        end

        class FigureRenderer
          include Base
          def render(node)
            name = node.fmt_name
            if name
              title = build_paragraph(Array(name.text).join,
                                      style: figure_title_style_id)
              doc << title
            end
            (node.image || []).each do |img|
              doc << build_paragraph("[image: #{img.src}]",
                                     style: resolver.lookup(:body_text) || "af")
            end
          end
          def figure_title_style_id = resolver.lookup(:figure_title) || "af"
        end

        class FormulaRenderer
          include Base
          def render(node)
            doc << build_paragraph(Array(node.text).join,
                                   style: resolver.lookup(:body_text) || "af")
          end
        end

        class SourcecodeRenderer
          include Base
          def render(node)
            Array(node.lines).each do |line|
              doc << build_paragraph(line,
                                     style: resolver.lookup(:sourcecode) || "af")
            end
          end
        end

        class QuoteRenderer
          include Base
          def render(node)
            Array(node.paragraphs).each do |p|
              text = Array(p.text).join
              para = build_paragraph(text, style: quote_style_id)
              doc << para
            end
          end
          def quote_style_id = resolver.lookup(:quote) || "af"
        end

        class DefinitionListRenderer
          include Base
          def render(node)
            Array(node.dl).each do |entry|
              dt = Array(entry.dt).join
              dd = Array(entry.dd).join
              doc << build_paragraph("#{dt}: #{dd}",
                                     style: resolver.lookup(:definition) || "af")
            end
          end
        end

        class PageBreakRenderer
          include Base
          def render(_node)
            doc.page_break
          end
        end

        class HorizontalRuleRenderer
          include Base
          def render(_node)
            para = build_paragraph("---", style: "a")
            doc << para
          end
        end
      end
    end
  end
end
