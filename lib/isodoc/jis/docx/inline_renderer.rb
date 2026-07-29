# frozen_string_literal: true

require "uniword"
require "metanorma/document"

module IsoDoc
  module Jis
    module Docx
      # Renders inline model elements to Uniword RunBuilder objects.
      # Walks ParagraphBlock#each_mixed_content in document order and
      # emits one RunBuilder per inline element with appropriate
      # formatting (bold, italic, subscript, etc.).
      #
      # Pure transformation: model node + ParagraphBuilder → populated
      # ParagraphBuilder. No state, no side effects beyond mutating the
      # passed paragraph builder.
      class InlineRenderer
        attr_reader :resolver

        def initialize(resolver)
          @resolver = resolver
        end

        def render(paragraph_block, para)
          return unless paragraph_block
          if paragraph_block.mixed_content?
            render_mixed(paragraph_block, para)
          else
            render_plain(paragraph_block, para)
          end
        end

        private

        def render_mixed(node, para)
          node.each_mixed_content do |value|
            case value
            when String then add_text_run(para, value)
            when Metanorma::Document::Components::Inline::EmRawElement
              add_formatted_run(para, value, :italic)
            when Metanorma::Document::Components::Inline::StrongRawElement
              add_formatted_run(para, value, :bold)
            when Metanorma::Document::Components::Inline::SubElement
              add_formatted_run(para, value, :subscript)
            when Metanorma::Document::Components::Inline::SupElement
              add_formatted_run(para, value, :superscript)
            when Metanorma::Document::Components::Inline::LinkElement
              add_link_run(para, value)
            when Metanorma::Document::Components::Inline::TtElement
              add_formatted_run(para, value, :character_style, resolver.lookup(:inline_code))
            when nil then next
            else
              add_text_run(para, extract_text(value))
            end
          end
        end

        def render_plain(node, para)
          text = node.text
          add_text_run(para, text) if text && !text.empty?
        end

        def add_text_run(para, text)
          return if text.nil? || text.to_s.empty?
          run = Uniword::Builder::RunBuilder.new
          run.text(text)
          para << run
        end

        def add_formatted_run(para, element, format, style_id = nil)
          run = Uniword::Builder::RunBuilder.new
          text = extract_text(element)
          run.text(text)
          case format
          when :bold then run.bold
          when :italic then run.italic
          when :subscript then run.subscript
          when :superscript then run.superscript
          when :underline then run.underline
          when :strike then run.strike
          when :character_style then run.character_style(style_id) if style_id
          end
          para << run
        end

        def add_link_run(para, element)
          run = Uniword::Builder::RunBuilder.new
          text = extract_text(element)
          run.text(text)
          link_style = resolver.lookup(:hyperlink)
          run.character_style(link_style) if link_style
          para << run
        end

        def extract_text(element)
          return element if element.is_a?(String)
          return "" if element.nil?
          text = nil
          if element.class.attributes.key?(:text)
            text = element.text
          elsif element.class.attributes.key?(:content)
            text = element.content
          end
          return "" if text.nil?
          return text if text.is_a?(String)
          text.is_a?(Array) ? text.join("") : text.to_s
        end
      end
    end
  end
end
