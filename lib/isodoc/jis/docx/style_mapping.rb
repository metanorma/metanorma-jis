# frozen_string_literal: true

require "yaml"

module IsoDoc
  module Jis
    module Docx
      # Template path + style mapping resolver for JIS DOCX output.
      # Mirrors IsoDoc::Iso::DocxTemplates + DocxStyleMapping.
      module StyleMapping
        DATA_DIR = File.expand_path("../../../../data/jis", __dir__)

        TEMPLATES = {
          jis: { file: "template.docx" },
        }.freeze

        def self.template_path(template_type = :jis)
          spec = TEMPLATES[template_type] || TEMPLATES[:jis]
          File.join(DATA_DIR, spec[:file])
        end

        def self.style_mapping_path
          File.join(DATA_DIR, "style_mapping.yml")
        end

        def self.load_mapping
          YAML.load_file(style_mapping_path)
        end
      end
    end
  end
end
