# frozen_string_literal: true

module IsoDoc
  module Jis
    module Docx
      module Renderers
        # Base module for all JIS renderers. Provides shared access to the
        # Uniword DocumentBuilder (passed as :doc to the constructor) and
        # the StyleResolver (passed as :resolver). No global state.
        # Renderers expose a single #render(node) entry point that emits
        # Uniword builders into the doc.
        module Base
          attr_reader :doc, :resolver, :context

          def initialize(doc:, resolver:, context: nil)
            @doc = doc
            @resolver = resolver
            @context = context
          end

          # Render a model node into the doc. Subclasses override this.
          def render(_node); raise NotImplementedError; end

          protected

          def build_paragraph(text, style:)
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = style
            run = Uniword::Builder::RunBuilder.new
            run.text(text.to_s)
            para << run
            para
          end

          def build_run(text)
            run = Uniword::Builder::RunBuilder.new
            run.text(text.to_s)
            run
          end
        end
      end
    end
  end
end
