require "asciidoctor"
require "metanorma-iso"
require_relative "./front"

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

      def boilerplate_file(_x_orig)
        File.join(@libdir, "jis_intro_jp.xml")
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

        return

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
          IsoDoc::JIS::PresentationXMLConvert.new(doc_extract_attributes(node))
        end
      end

      def script_validate(xmldoc)
        script = xmldoc&.at("//bibdata/script")&.text
        %w(Jpan Latn).include?(script) or
          @log.add("Document Attributes", nil,
                   "#{script} is not a recognised script")
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "jis.rng"))
      end
    end
  end
end
