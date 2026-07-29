# frozen_string_literal: true

require "uniword"

module IsoDoc
  module Jis
    module Docx
      # Converts a JIS presentation XML to DOCX via Uniword. Mirrors
      # IsoDoc::Iso::Docx::Adapter:
      #
      #   metanorma-jis model → Adapter → Uniword builders → DOCX
      #
      # The Adapter loads a template DOCX via Uniword.load, clears the
      # body, walks the typed model, and saves via DocumentWriter.
      class Adapter
        attr_reader :resolver, :template_path

        def initialize(template: :jis, template_path: nil)
          @template_path = template_path || StyleMapping.template_path(template)
          @resolver = StyleResolver.new
        end

        def convert(xml_input, output_path)
          model = parse_xml(xml_input)
          doc = create_document
          reset_state
          visit_root(model, doc)
          save_document(doc.model, output_path)
        end

        private

        def parse_xml(source)
          xml = read_source(source)
          Metanorma::Jis::Document::Root.from_xml(xml)
        end

        def read_source(source)
          case source
          when String
            File.exist?(source) ? File.read(source, encoding: "utf-8") : source
          else
            source.to_s
          end
        end

        def create_document
          unless @template_path && File.exist?(@template_path)
            raise Errors::MissingTemplateError,
                  "template not found at #{@template_path.inspect}"
          end
          @template_root ||= Uniword.load(@template_path)
          root = @template_root
          if root.body
            root.body.paragraphs.clear
            root.body.tables.clear
            root.body.structured_document_tags.clear
            root.body.bookmark_starts.clear
            root.body.bookmark_ends.clear
            root.body.element_order = [] if root.body.element_order
          end
          Uniword::Builder::DocumentBuilder.new(root,
                                                allocator: root.allocator)
        end

        def reset_state
          @cover_renderer = CoverRenderer.new(@resolver)
          @body_renderer = BodyRenderer.new(@resolver)
        end

        def visit_root(model, doc)
          @cover_renderer.render(model.cover, doc)
          doc.page_break if model.cover
          @body_renderer.render(model, doc)
        end

        def save_document(model, output_path)
          Uniword::DocumentWriter.new(model).save(output_path)
        rescue StandardError => e
          warn "[metanorma-jis] DOCX save failed: #{e.message}"
          raise
        end
      end
    end
  end
end
