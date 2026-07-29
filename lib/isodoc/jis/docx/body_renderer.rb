# frozen_string_literal: true

require "uniword"

module IsoDoc
  module Jis
    module Docx
      class BodyRenderer
        attr_reader :resolver

        def initialize(resolver)
          @resolver = resolver
        end

        def render(root_model, doc)
          render_clause(root_model.foreword, doc) if root_model.foreword
          render_clause(root_model.introduction, doc) if root_model.introduction
          render_sections(root_model, doc)
          root_model.annex&.each { |a| render_annex(a, doc) }
        end

        private

        def render_sections(root_model, doc)
          sections = root_model.sections or return
          sections.clause&.each { |c| render_clause(c, doc) }
          sections.references&.each { |r| render_clause(r, doc) }
        end

        def render_annex(annex, doc)
          doc.page_break
          render_clause(annex, doc)
        end

        def render_clause(clause, doc, level = 1)
          return unless clause
          render_title(clause, doc, level)
          render_block_children(clause, doc, level)
        end

        def render_title(clause, doc, level)
          title = clause.fmt_title || clause.title
          return unless title
          text = title.is_a?(String) ? title : title.text
          return if text.to_s.empty?
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = heading_style(level)
          run = Uniword::Builder::RunBuilder.new
          run.text(text)
          para << run
          doc << para
        end

        def render_block_children(clause, doc, level)
          clause.paragraphs&.each { |p| render_paragraph(p, doc) }
          clause.unordered_lists&.each { |l| render_list(l, doc) }
          clause.ordered_lists&.each { |l| render_list(l, doc) }
          clause.tables&.each { |t| render_table(t, doc) }
          clause.figures&.each { |f| render_figure(f, doc) }
          clause.notes&.each { |n| render_note(n, doc) }
          clause.examples&.each { |e| render_example(e, doc) }
          clause.admonitions&.each { |a| render_admonition(a, doc) }
          clause.clause&.each { |c| render_clause(c, doc, level + 1) }
          clause.terms&.each { |t| render_clause(t, doc, level + 1) }
          clause.definitions&.each { |d| render_clause(d, doc, level + 1) }
          clause.references&.each { |r| render_clause(r, doc, level + 1) }
        end

        def render_paragraph(para_block, doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = body_style
          inline_renderer.render(para_block, para)
          doc << para
        end

        def render_list(list, doc)
          items = list.items || []
          items.each do |item|
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = body_style
            run = Uniword::Builder::RunBuilder.new
            run.text("・ #{item}")
            para << run
            doc << para
          end
        end

        def render_table(table, doc)
          tbl = Uniword::Builder::TableBuilder.new
          doc << tbl
        end

        def render_note(note, doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = resolver.lookup(:note) || body_style
          run = Uniword::Builder::RunBuilder.new
          run.text(note.to_s)
          para << run
          doc << para
        end

        def render_example(example, doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = resolver.lookup(:example) || body_style
          run = Uniword::Builder::RunBuilder.new
          run.text(example.to_s)
          para << run
          doc << para
        end

        def render_admonition(admonition, doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = body_style
          run = Uniword::Builder::RunBuilder.new
          run.text(admonition.to_s)
          para << run
          doc << para
        end

        def render_figure(figure, doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = body_style
          run = Uniword::Builder::RunBuilder.new
          run.text("[Figure]")
          para << run
          doc << para
        end

        def render_terms(terms_section, doc, level)
          render_clause(terms_section, doc, level)
        end

        def heading_style(level)
          resolver.lookup("heading#{level}".to_sym) || body_style
        end

        def body_style
          resolver.lookup(:body_text) || "a"
        end

        def inline_renderer
          @inline_renderer ||= InlineRenderer.new(resolver)
        end
      end
    end
  end
end
