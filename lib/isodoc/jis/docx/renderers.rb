# frozen_string_literal: true

module IsoDoc
  module Jis
    module Docx
      module Renderers
        autoload :Base, "isodoc/jis/docx/renderers/base"
        autoload :Registry, "isodoc/jis/docx/renderers/registry"
        autoload :ParagraphRenderer, "isodoc/jis/docx/renderers/paragraph"
        autoload :ClauseRenderer, "isodoc/jis/docx/renderers/clause"
        autoload :AnnexRenderer, "isodoc/jis/docx/renderers/clause"
        autoload :OrderedListRenderer, "isodoc/jis/docx/renderers/order"
        autoload :UnorderedListRenderer, "isodoc/jis/docx/renderers/order"
        autoload :TableRenderer, "isodoc/jis/docx/renderers/table"
        autoload :AdmonitionRenderer, "isodoc/jis/docx/renderers/blocks"
        autoload :DefinitionListRenderer, "isodoc/jis/docx/renderers/blocks"
        autoload :ExampleRenderer, "isodoc/jis/docx/renderers/blocks"
        autoload :FigureRenderer, "isodoc/jis/docx/renderers/blocks"
        autoload :FormulaRenderer, "isodoc/jis/docx/renderers/blocks"
        autoload :HorizontalRuleRenderer, "isodoc/jis/docx/renderers/blocks"
        autoload :NoteRenderer, "isodoc/jis/docx/renderers/blocks"
        autoload :PageBreakRenderer, "isodoc/jis/docx/renderers/blocks"
        autoload :QuoteRenderer, "isodoc/jis/docx/renderers/blocks"
        autoload :SourcecodeRenderer, "isodoc/jis/docx/renderers/blocks"
        autoload :AmendRenderer, "isodoc/jis/docx/renderers/sections"
        autoload :CommentaryRenderer, "isodoc/jis/docx/renderers/sections"
        autoload :DefinitionsRenderer, "isodoc/jis/docx/renderers/sections"
        autoload :IndexRenderer, "isodoc/jis/docx/renderers/sections"
        autoload :ReferencesRenderer, "isodoc/jis/docx/renderers/sections"
        autoload :SectionsContainerRenderer, "isodoc/jis/docx/renderers/sections"
        autoload :SectionsRenderer, "isodoc/jis/docx/renderers/sections"
        autoload :TermSectionRenderer, "isodoc/jis/docx/renderers/sections"
      end
    end
  end
end
