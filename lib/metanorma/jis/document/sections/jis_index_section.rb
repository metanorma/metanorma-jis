# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Jis
    module Document
      module Sections
        # JIS dual-alphabet index — かな (Japanese syllabary) + Latin.
        # Two child groups, one per alphabet. The Adapter's IndexRenderer
        # emits both groups with distinct headings.
        #
        # Validation: at most one of each group; either may be absent.
        class JisIndexSection < Lutaml::Model::Serializable
          attribute :kana_index, :string, collection: true
          attribute :latin_index, :string, collection: true

          xml do
            element "index"
            ordered

            map_element "kana-index", to: :kana_index
            map_element "latin-index", to: :latin_index
          end
        end
      end
    end
  end
end
