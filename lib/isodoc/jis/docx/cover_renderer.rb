# frozen_string_literal: true

require "uniword"

module IsoDoc
  module Jis
    module Docx
      # Renders the JIS cover page from the model's Cover attributes.
      # Uses Uniword's Builder API directly — no HTML, no Nokogiri.
      class CoverRenderer
        attr_reader :resolver

        def initialize(resolver)
          @resolver = resolver
        end

        def render(cover, doc)
          return unless cover
          render_line(doc, "日本工業規格")
          render_line(doc, cover.docidentifier) if cover.docidentifier
          render_line(doc, cover.title_ja) if cover.title_ja
          render_line(doc, cover.title_en) if cover.title_en
          render_line(doc, cover.committee) if cover.committee
          render_intl_marker(doc, cover)
        end

        private

        def render_line(doc, text)
          return if text.nil? || text.to_s.empty?
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = resolver.lookup(:body_text) || "a"
          run = Uniword::Builder::RunBuilder.new
          run.text(text)
          para << run
          doc << para
        end

        def render_intl_marker(doc, cover)
          marker = intl_marker(cover.intl_alignment)
          return unless marker
          render_line(doc, "(#{marker})")
        end

        def intl_marker(alignment)
          case alignment.to_s
          when "idt" then "IDT"
          when "mod" then "MOD"
          when "neq" then "NEQ"
          end
        end
      end
    end
  end
end
