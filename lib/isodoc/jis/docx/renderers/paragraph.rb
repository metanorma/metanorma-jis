# frozen_string_literal: true

module IsoDoc
  module Jis
    module Docx
      module Renderers
        # Renders a paragraph block. Walks the paragraph's mixed content
        # via InlineRenderer, producing one ParagraphBuilder with one or
        # more RunBuilders (bold/italic/sub/sup/links).
        class ParagraphRenderer
          include Base

          def render(node)
            para = Uniword::Builder::ParagraphBuilder.new
            apply_style(para, node)
            render_inline(node, para)
            para
          end

          private

          def apply_style(para, node)
            style = node.class_attr || lookup_style_hint(node)
            para.style = style if style
          end

          def lookup_style_hint(node)
            hint = node.class_attr.to_s.downcase.to_sym
            resolver.lookup(hint)
          rescue StandardError
            nil
          end

          def render_inline(node, para)
            inline_renderer.render(node, para)
          end

          def inline_renderer
            @inline_renderer ||= InlineRenderer.new(doc: doc, resolver: resolver)
          end
        end
      end
    end
  end
end
