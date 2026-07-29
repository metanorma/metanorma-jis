# frozen_string_literal: true

module IsoDoc
  module Jis
    module Docx
      # Resolves semantic style keys to DOCX styleIds. Strict: raises
      # UnknownStyleError on miss.
      class StyleResolver
        attr_reader :mapping

        def initialize(mapping_data = StyleMapping.load_mapping)
          @mapping = mapping_data
        end

        def paragraph_style(key)
          style = @mapping["paragraph_styles"][key.to_s]
          if style.nil? || style == "TODO"
            raise Errors::UnknownStyleError,
                  "no paragraph_style mapping for #{key.inspect}"
          end
          style
        end

        def lookup(key)
          style = @mapping["paragraph_styles"][key.to_s] ||
                  @mapping["character_styles"][key.to_s]
          (style.nil? || style == "TODO") ? nil : style
        end
      end
    end
  end
end
