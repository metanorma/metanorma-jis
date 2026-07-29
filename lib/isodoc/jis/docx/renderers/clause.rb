# frozen_string_literal: true

module IsoDoc
  module Jis
    module Docx
      module Renderers
        # Renders a clause (JisClauseSection or IsoClauseSection).
        # Emits the clause title as a heading, then walks child blocks
        # via the Registry.
        class ClauseRenderer
          include Base
          def render(node)
            render_title(node)
            render_children(node)
          end
          def render_title(node)
            title_text = extract_title(node)
            return if title_text.nil? || title_text.empty?
            style = heading_style_id(clause_level(node))
            doc << build_paragraph(title_text, style: style)
          end
          def render_children(node)
            registry = Registry.new(doc: doc, resolver: resolver)
            child_blocks(node).each { |block| registry.render(block) }
            child_clauses(node).each { |clause| registry.render(clause) }
          end
          def child_blocks(node)
            blocks = []
            blocks.concat(Array(node.paragraphs))
            blocks.concat(Array(node.unordered_lists))
            blocks.concat(Array(node.ordered_lists))
            blocks.concat(Array(node.tables))
            blocks.concat(Array(node.figures))
            blocks.concat(Array(node.formulas))
            blocks.concat(Array(node.examples))
            blocks.concat(Array(node.notes))
            blocks.concat(Array(node.admonitions))
            blocks.concat(Array(node.sourcecode_blocks))
            blocks.concat(Array(node.quote_blocks))
            blocks.concat(Array(node.definition_lists))
            blocks
          end
          def child_clauses(node) = Array(node.clause)
          def extract_title(node)
            fmt_title = node.fmt_title
            return Array(fmt_title.text).join if fmt_title
            title = node.title
            title ? Array(title.text).join : nil
          end
          def clause_level(_node) = 1
          def heading_style_id(level) = resolver.lookup("heading#{level}".to_sym) || "afffff4"
        end

        # JisAnnexSection reuses ClauseRenderer logic but uses
        # the annex heading style for top-level annexes.
        class AnnexRenderer < ClauseRenderer
          def heading_style_id(level)
            return resolver.lookup(:annex) || "ae" if level == 1
            super
          end
        end
      end
    end
  end
end
