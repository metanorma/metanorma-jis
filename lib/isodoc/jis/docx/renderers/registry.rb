# frozen_string_literal: true

module IsoDoc
  module Jis
    module Docx
      module Renderers
        # Class-keyed dispatch from model class to renderer class.
        # Mirrors metanorma-iso's Renderers::Registry.
        #
        # Uses class-name strings (lazy resolution) so the table can
        # reference classes that may not all be loaded at table
        # definition time. Adding a new block type = adding one entry
        # to the table. OCP: no edit to render() dispatch logic.
        class Registry
          BLOCK_RENDERERS = {
            "Metanorma::Document::Components::Paragraphs::ParagraphBlock" => :ParagraphRenderer,
            "Metanorma::Document::Components::Tables::TableBlock" => :TableRenderer,
            "Metanorma::Document::Components::Lists::OrderedList" => :OrderedListRenderer,
            "Metanorma::Document::Components::Lists::UnorderedList" => :UnorderedListRenderer,
            "Metanorma::Document::Components::Lists::DefinitionList" => :DefinitionListRenderer,
            "Metanorma::Document::Components::Blocks::NoteBlock" => :NoteRenderer,
            "Metanorma::Document::Components::AncillaryBlocks::ExampleBlock" => :ExampleRenderer,
            "Metanorma::Document::Components::MultiParagraph::AdmonitionBlock" => :AdmonitionRenderer,
            "Metanorma::Document::Components::MultiParagraph::QuoteBlock" => :QuoteRenderer,
            "Metanorma::Document::Components::AncillaryBlocks::FigureBlock" => :FigureRenderer,
            "Metanorma::Document::Components::AncillaryBlocks::FormulaBlock" => :FormulaRenderer,
            "Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock" => :SourcecodeRenderer,
          }.freeze

          SECTION_RENDERERS = {
            "Metanorma::Jis::Document::Sections::JisSections" => :SectionsRenderer,
            "Metanorma::Jis::Document::Sections::JisCommentarySection" => :CommentaryRenderer,
            "Metanorma::Jis::Document::Sections::JisIndexSection" => :IndexRenderer,
            "Metanorma::Document::Components::Sections::ReferencesSection" => :ReferencesRenderer,
          }.freeze

          CLAUSE_RENDERERS = {
            "Metanorma::IsoDocument::Sections::IsoClauseSection" => :ClauseRenderer,
            "Metanorma::Jis::Document::Sections::JisClauseSection" => :ClauseRenderer,
            "Metanorma::IsoDocument::Sections::IsoAnnexSection" => :AnnexRenderer,
            "Metanorma::Jis::Document::Sections::JisAnnexSection" => :AnnexRenderer,
          }.freeze

          SPECIAL_RENDERERS = {
            "Metanorma::Document::Components::EmptyElements::PageBreakElement" => :PageBreakRenderer,
            "Metanorma::Document::Components::EmptyElements::HorizontalRuleElement" => :HorizontalRuleRenderer,
          }.freeze

          def initialize(doc:, resolver:)
            @doc = doc
            @resolver = resolver
            @instances = {}
          end

          def render(node)
            renderer_symbol = lookup(node.class.name)
            return nil unless renderer_symbol
            @instances[renderer_symbol] ||= build_renderer(renderer_symbol)
            @instances[renderer_symbol].render(node)
          end

          private

          def lookup(class_name)
            BLOCK_RENDERERS[class_name] ||
              SECTION_RENDERERS[class_name] ||
              CLAUSE_RENDERERS[class_name] ||
              SPECIAL_RENDERERS[class_name]
          end

          def build_renderer(renderer_symbol)
            klass = Renderers.const_get(renderer_symbol)
            klass.new(doc: @doc, resolver: @resolver)
          end
        end
      end
    end
  end
end
