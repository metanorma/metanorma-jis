# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Jis
    module Document
      module Sections
        # JIS annex — may carry `commentary: bool` to mark it as belonging
        # to the 解説 (commentary) appendix. The presentation converter
        # already sets `clause[@commentary='true']` in semantic XML
        # (lib/metanorma/jis/converter.rb:30-38); this model surfaces that
        # attribute as a typed boolean.
        class JisAnnexSection < Metanorma::IsoDocument::Sections::IsoAnnexSection
          attribute :commentary, :boolean

          xml do
            element "annex"
            ordered

            map_attribute "commentary", to: :commentary
          end
        end
      end
    end
  end
end
