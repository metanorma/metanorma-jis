require "asciidoctor"
require "metanorma-iso"
require_relative "front"
require_relative "validate"
require_relative "cleanup"

module Metanorma
  module JIS
    class Converter < ISO::Converter
      XML_ROOT_TAG = "jis-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/jis".freeze

      register_for "jis"

      def init_i18n(node)
        node.attr("language") or node.set_attr("language", "ja")
        node.attr("language") == "jp" and node.set_attr("language", "ja")
        super
      end

      def doctype(node)
        ret = node.attr("doctype")&.gsub(/\s+/, "-")&.downcase ||
          "japanese-industrial-standard"
        ret = "japanese-industrial-standard" if ret == "article"
        ret
      end

      def section_attributes(node)
        ret = super
        if node.attr("style") == "appendix" && node.level == 1 &&
            node.option?("commentary")
          ret[:commentary] = true
          node.set_attr("obligation", "informative")
        end
        ret
      end

      def example_attrs(node)
        attr_code(id_unnum_attrs(node).merge(keep_attrs(node))
          .merge("keep-separate": node.attr("keep-separate")))
      end

      def boilerplate_file(_x_orig)
        File.join(@libdir, "boilerplate-#{@lang}.adoc")
      end

      def html_converter(node)
        if node.nil?
          IsoDoc::JIS::HtmlConvert.new({})
        else
          IsoDoc::JIS::HtmlConvert.new(html_extract_attributes(node))
        end
      end

      def doc_converter(node)
        if node.nil?
          IsoDoc::JIS::WordConvert.new({})
        else
          IsoDoc::JIS::WordConvert.new(doc_extract_attributes(node))
        end
      end

      def pdf_converter(node)
        return if node.attr("no-pdf")

        if node.nil?
          IsoDoc::JIS::PdfConvert.new({})
        else
          IsoDoc::JIS::PdfConvert.new(pdf_extract_attributes(node))
        end
      end

      def presentation_xml_converter(node)
        if node.nil?
          IsoDoc::JIS::PresentationXMLConvert.new({})
        else
          IsoDoc::JIS::PresentationXMLConvert
            .new(doc_extract_attributes(node)
            .merge(output_formats: ::Metanorma::JIS::Processor.new.output_formats))
        end
      end
    end
  end
end
