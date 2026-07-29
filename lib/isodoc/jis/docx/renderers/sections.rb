# frozen_string_literal: true

module IsoDoc
  module Jis
    module Docx
      module Renderers
        # Section renderers. Each handles one section model type and
        # dispatches its child blocks via Registry.for_class.

        class SectionsContainerRenderer
          include Base
          def render(node)
            children = Array(node.clause)
            children.each { |clause| render_child(clause) }
          end
          def render_child(clause)
            registry = Registry.new(doc: doc, resolver: resolver)
            registry.render(clause)
          end
        end

        # Alias for SectionsContainer (some metanorma-document versions
        # name it differently).
        SectionsRenderer = SectionsContainerRenderer

        class ReferencesRenderer
          include Base
          def render(node)
            title = build_paragraph("引用規格", style: bibliography_style_id)
            doc << title
            Array(node.bibitem).each do |bib|
              doc << build_paragraph(bib_text(bib),
                                     style: biblio_entry_style_id)
            end
          end
          def bibliography_style_id = resolver.lookup(:bibliography) || "aff1"
          def biblio_entry_style_id = resolver.lookup(:biblio_entry) || "af"
          def bib_text(bib)
            id = Array(bib.docidentifier).join
            title = Array(bib.title).join
            "#{id}　#{title}".strip
          end
        end

        class TermSectionRenderer
          include Base
          def render(node)
            Array(node.term).each do |term|
              render_term(term)
            end
          end
          def render_term(term)
            preferred = term.preferred
            text = preferred ? Array(preferred.text).join : ""
            doc << build_paragraph(text, style: term_style_id)
          end
          def term_style_id = resolver.lookup(:terms) || "af"
        end

        class DefinitionsRenderer
          include Base
          def render(node)
            title = build_paragraph("定義", style: heading_style_id(1))
            doc << title
          end
          def heading_style_id(level) = resolver.lookup("heading#{level}".to_sym) || "afffff4"
        end

        class CommentaryRenderer
          include Base
          def render(node)
            title = build_paragraph("解説", style: heading_style_id(1))
            doc << title
          end
          def heading_style_id(level) = resolver.lookup("heading#{level}".to_sym) || "afffff4"
        end

        class IndexRenderer
          include Base
          def render(node)
            title = build_paragraph("索引", style: heading_style_id(1))
            doc << title
          end
          def heading_style_id(level) = resolver.lookup("heading#{level}".to_sym) || "afffff4"
        end

        class AmendRenderer
          include Base
          def render(node)
            doc << build_paragraph("[amend]", style: "af")
          end
        end
      end
    end
  end
end
