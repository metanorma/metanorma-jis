# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Jis
    module Document
      # Cover metadata for JIS documents. Single class with doctype-driven
      # field presence — behavior is identical, only data varies. The cover
      # layout is selected by `doctype` in the Adapter's CoverRenderer.
      #
      # Fields are populated from `<bibdata>` in the presentation XML. The
      # Liquid templates in lib/metanorma/jis/boilerplate/ consume these
      # fields when rendering the cover page.
      class Cover < Lutaml::Model::Serializable
        JIS_DOCTYPES = %w[
          japanese-industrial-standard
          technical-report
          technical-specification
          amendment
          technical-corrigendum
        ].freeze

        INTERNATIONAL_ALIGNMENT = %i[idt mod neq none].freeze

        attribute :doctype, :string
        attribute :docidentifier, :string
        attribute :docidentifier_undated, :string
        attribute :docnumber, :string
        attribute :year, :string
        attribute :committee, :string
        attribute :title_ja, :string
        attribute :title_en, :string
        attribute :intl_alignment, :symbol
        attribute :parent_docidentifier, :string

        def valid_doctype?
          JIS_DOCTYPES.include?(doctype)
        end

        def valid_alignment?
          INTERNATIONAL_ALIGNMENT.include?(intl_alignment)
        end

        def dual_language?
          !title_ja.to_s.empty? && !title_en.to_s.empty?
        end

        def amendment?
          doctype == "amendment" || doctype == "technical-corrigendum"
        end

        xml do
          element "bibdata"
          map_element "doctype", to: :doctype
          map_element "docidentifier", to: :docidentifier
          map_element "docnumber", to: :docnumber
        end
      end
    end
  end
end
