require "asciidoctor"
require "metanorma-iso"
require_relative "front"
require_relative "validate"
require_relative "cleanup"

module Metanorma
  module Jis
    class Converter < Iso::Converter
      XML_ROOT_TAG = "jis-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/jis".freeze

      register_for "jis"

      def init_i18n(node)
        node.attr("language") or node.set_attr("language", "ja")
        node.attr("language") == "jp" and node.set_attr("language", "ja")
        super
      end

      def init_misc(node)
        super
        @default_doctype = "japanese-industrial-standard"
      end

      def ol_attrs(node)
        ret = super
        ret.delete(:type)
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

      def document_scheme(node)
        node.attr("document-scheme")
      end

      def html_converter(node)
        if node.nil?
          IsoDoc::Jis::HtmlConvert.new({})
        else
          IsoDoc::Jis::HtmlConvert.new(html_extract_attributes(node))
        end
      end

      def doc_converter(node)
        if node.nil?
          IsoDoc::Jis::WordConvert.new({})
        else
          IsoDoc::Jis::WordConvert.new(doc_extract_attributes(node))
        end
      end

      def pdf_converter(node)
        return if node.attr("no-pdf")

        if node.nil?
          IsoDoc::Jis::PdfConvert.new({})
        else
          IsoDoc::Jis::PdfConvert.new(pdf_extract_attributes(node))
        end
      end

      def presentation_xml_converter(node)
        if node.nil?
          IsoDoc::Jis::PresentationXMLConvert.new({})
        else
          IsoDoc::Jis::PresentationXMLConvert
            .new(doc_extract_attributes(node)
            .merge(output_formats: ::Metanorma::Jis::Processor.new
            .output_formats))
        end
      end
    end
  end
end
