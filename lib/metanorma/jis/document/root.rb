# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Jis
    module Document
      class Root < Lutaml::Model::Serializable
        attribute :cover, Cover
        attribute :foreword, Metanorma::Jis::Document::Sections::JisClauseSection
        attribute :introduction, Metanorma::Jis::Document::Sections::JisClauseSection
        attribute :sections, Metanorma::Jis::Document::Sections::JisSections
        attribute :annex, Metanorma::Jis::Document::Sections::JisAnnexSection,
                  collection: true
        attribute :commentary, Metanorma::Jis::Document::Sections::JisCommentarySection,
                  collection: true
        attribute :index, Metanorma::Jis::Document::Sections::JisIndexSection

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
