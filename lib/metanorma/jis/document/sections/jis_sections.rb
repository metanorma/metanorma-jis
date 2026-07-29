# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Jis
    module Document
      module Sections
        # Container for the JIS <sections> element. Inherits clause, terms,
        # definitions, references, etc. from IsoSections — JIS doesn't
        # add new child types, only customizes rendering via styleIds.
        class JisSections < Metanorma::IsoDocument::Sections::IsoSections
          xml do
            element "sections"
            ordered
          end
        end
      end
    end
  end
end
