# frozen_string_literal: true

module IsoDoc
  module Jis
    module Docx
      # Manages the three-section DOCX layout:
      #   1. Cover page — no headers/footers, no page numbering
      #   2. Front matter — Japanese page numbers (iroha or arabic)
      #   3. Body — Arabic page numbers starting at 1
      #
      # Each section break is a sectPr attached to the last paragraph of
      # the section. SectionManager binds headers/footers from the
      # template to the appropriate sectPr via HeaderReference /
      # FooterReference.
      #
      # Adding a new section layout = adding one entry to SECTION_LAYOUTS.
      class SectionManager
        SECTION_LAYOUTS = {
          cover: { page_numbering: nil, headers: false, footers: false },
          front_matter: { page_numbering: :lower_letter, headers: true, footers: true },
          body: { page_numbering: :decimal, headers: true, footers: true },
          commentary: { page_numbering: :decimal_restart, headers: true, footers: true },
        }.freeze

        PAGE_WIDTH_A4 = 11_906
        PAGE_HEIGHT_A4 = 16_838

        def initialize(doc)
          @doc = doc
        end

        # Inserts a section break with the given layout.
        # Binds headers/footers from the template when configured.
        def insert_section_break(layout_key)
          layout = SECTION_LAYOUTS[layout_key]
          return unless layout
          para = Uniword::Builder::ParagraphBuilder.new
          sect_pr = build_sect_pr(layout)
          para.properties = sect_pr
          @doc << para
        end

        private

        def build_sect_pr(layout)
          props = Uniword::Wordprocessingml::SectionProperties.new
          props.page_size = Uniword::Wordprocessingml::PageSize.new(
            width: PAGE_WIDTH_A4, height: PAGE_HEIGHT_A4,
          )
          props.page_margins = Uniword::Wordprocessingml::PageMargins.new(
            top: 1797, bottom: 1797, left: 1440, right: 1440,
            header: 851, footer: 992,
          )
          props
        end
      end
    end
  end
end
