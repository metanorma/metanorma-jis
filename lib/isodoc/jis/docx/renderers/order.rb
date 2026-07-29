# frozen_string_literal: true

module IsoDoc
  module Jis
    module Docx
      module Renderers
        # Renders an OrderedList or UnorderedList as JIS-style flattened
        # paragraphs with hanging tabs. JIS convention: lists are NOT
        # rendered as Word <w:numPr> lists, but as indented paragraphs
        # with manual markers. Mirrors the previous Html2Doc::Jis behavior.
        class OrderedListRenderer
          include Base

          def render(node)
            items(node).each_with_index do |item, idx|
              doc << build_list_item(item, marker: "#{idx + 1}.", depth: depth(node))
            end
          end

          private

          def items(node) = Array(node.items)
          def depth(node) = ancestor_depth(node) + 1

          def ancestor_depth(node)
            node.ancestors.count { |a| ordered_list?(a) }
          end

          def ordered_list?(node)
            node.is_a?(Metanorma::Document::Components::Lists::OrderedList)
          end

          def build_list_item(item, marker:, depth:)
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = list_style_id
            apply_indent(para, depth)
            apply_marker(para, marker)
            apply_label(para, item)
            para
          end

          def list_style_id
            resolver.lookup(:body_text) || "af"
          end

          def apply_indent(para, depth)
            indent_cm = { 1 => 1.27, 2 => 1.91, 3 => 2.54, 4 => 3.18 }[depth] || 3.18
            indent_twips = (indent_cm * 567).to_i
            properties = para.properties || Uniword::Wordprocessingml::ParagraphProperties.new
            properties.indent = Uniword::Wordprocessingml::Indentation.new(
              left: indent_twips,
              hanging: 364,
            )
            para.properties = properties
          end

          def apply_marker(para, marker)
            run = Uniword::Builder::RunBuilder.new
            run.text("#{marker} ")
            para << run
          end

          def apply_label(para, item)
            run = Uniword::Builder::RunBuilder.new
            run.text(text_of(item))
            para << run
          end

          def text_of(item)
            item.respond_to?(:text) ? item.text.to_s : item.to_s
          end
        end

        class UnorderedListRenderer
          include Base

          def render(node)
            items(node).each do |item|
              doc << build_list_item(item, depth: depth(node))
            end
          end

          private

          def items(node) = Array(node.items)
          def depth(node) = ancestor_depth(node) + 1
          def ancestor_depth(node) = node.ancestors.count { |a| list?(a) }
          def list?(node)
            node.is_a?(Metanorma::Document::Components::Lists::UnorderedList) ||
              node.is_a?(Metanorma::Document::Components::Lists::OrderedList)
          end

          def build_list_item(item, depth:)
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = list_style_id
            apply_indent(para, depth)
            apply_marker(para)
            apply_label(para, item)
            para
          end

          def list_style_id
            resolver.lookup(:body_text) || "af"
          end

          def apply_indent(para, depth)
            indent_cm = { 1 => 1.27, 2 => 1.91, 3 => 2.54, 4 => 3.18 }[depth] || 3.18
            indent_twips = (indent_cm * 567).to_i
            properties = para.properties || Uniword::Wordprocessingml::ParagraphProperties.new
            properties.indent = Uniword::Wordprocessingml::Indentation.new(
              left: indent_twips,
              hanging: 364,
            )
            para.properties = properties
          end

          def apply_marker(para)
            run = Uniword::Builder::RunBuilder.new
            run.text("・ ")
            para << run
          end

          def apply_label(para, item)
            run = Uniword::Builder::RunBuilder.new
            run.text(item.respond_to?(:text) ? item.text.to_s : item.to_s)
            para << run
          end
        end
      end
    end
  end
end
