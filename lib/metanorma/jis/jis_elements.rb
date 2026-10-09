# frozen_string_literal: true

require "relaton-render"

module Metanorma
  module Jis
    # JIS-specific data elements extending the engine's ISO 690
    # vocabulary, passed to the renderer as its element map
    module JisElements
      HOME_PUBLISHERS = [
        "International Organization for Standardization", "ISO",
        "International Electrotechnical Commission", "IEC",
        "日本規格協会", "一般財団法人　日本規格協会",
        "Japanese Industrial Standards",
      ].freeze

      # The JIS presentation-of-models rules (component part, series,
      # extent) are engine-registered (jis_*) since relaton-render
      # 3.0.0.pre.alpha.39 and selected as pack data in the styles

      class JisRenderer < ::Relaton::Render::Iso690::Renderer
        def home_docid?(model)
          JisElements.home_publisher?(model)
        end
      end

      module_function

      def home_publisher?(model)
        Array(model.contributor).any? do |c|
          next false unless Array(c.role).any? do |r|
            r.is_a?(String) ? r == "publisher" : r.type == "publisher"
          end

          Array(c.organization&.name).any? do |n|
            HOME_PUBLISHERS.include?(n.content)
          end
        end
      end
    end
  end
end
