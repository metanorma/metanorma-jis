# frozen_string_literal: true

require "lutaml/model"

module IsoDoc
  module Jis
    module Docx
      module Model
        class Root < Lutaml::Model::Serializable
          attribute :cover, Cover
          attribute :foreword, IsoDoc::Jis::Docx::Model::Sections::JisClauseSection
          attribute :introduction, IsoDoc::Jis::Docx::Model::Sections::JisClauseSection
          attribute :sections, IsoDoc::Jis::Docx::Model::Sections::JisSections
          attribute :annex, IsoDoc::Jis::Docx::Model::Sections::JisAnnexSection,
                    collection: true
          attribute :commentary, IsoDoc::Jis::Docx::Model::Sections::JisCommentarySection,
                    collection: true
          attribute :index, IsoDoc::Jis::Docx::Model::Sections::JisIndexSection

          xml do
            element "jis-standard"
            namespace Namespace

            map_element "bibdata", to: :cover
            map_element "foreword", to: :foreword
            map_element "introduction", to: :introduction
            map_element "sections", to: :sections
            map_element "annex", to: :annex
            map_element "commentary", to: :commentary
            map_element "index", to: :index
          end
        end
      end
    end
  end
end
