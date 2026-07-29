# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Jis
    module Document
      module Sections
        # JIS clause — body section. Inherits all behavior from the shared
        # IsoClauseSection; JIS-specific numbering is produced by the
        # presentation XML (presentation_section.rb), so this model only
        # carries typed identity.
        #
        # When the Adapter dispatches on class, it routes JisClauseSection
        # to Renderers::ClauseRenderer (or similar). Adding a new clause
        # variant = subclassing this + registering a renderer.
        class JisClauseSection < Metanorma::IsoDocument::Sections::IsoClauseSection
          xml do
            element "clause"
            ordered
          end
        end
      end
    end
  end
end
