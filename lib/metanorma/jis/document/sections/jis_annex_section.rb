# frozen_string_literal: true

module Metanorma
  module Jis::Document
    module Sections
      class JisAnnexSection < Metanorma::IsoDocument::Sections::IsoAnnexSection
        attribute :commentary, :boolean

        xml do
          element "annex"
          ordered

          Metanorma::Standoc::Document::SectionXmlMapping.apply_annex_attributes(self)
          map_attribute "commentary", to: :commentary
          Metanorma::Standoc::Document::SectionXmlMapping.apply_annex_elements(self)
        end
      end
    end
  end
end