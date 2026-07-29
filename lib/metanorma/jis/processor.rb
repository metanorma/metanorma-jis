require "metanorma/processor"

module Metanorma
  module Jis
    class Processor < Metanorma::Processor

      def initialize # rubocop:disable Lint/MissingSuper
        @short = :jis
        @input_format = :asciidoc
        @asciidoctor_backend = :jis
      end

      def output_formats
        super.merge(
          html: "html",
          pdf: "pdf",
          docx: "docx",
        )
      end

      def fonts_manifest
        {
          "STIX Two Math" => nil,
          "IPAexGothic" => nil,
          "IPAexMincho" => nil,
          "MS Mincho" => nil,
          "MS Gothic" => nil,
          "Courier New" => nil,
          "Cambria Math" => nil,
          "Times New Roman" => nil,
          "Arial" => nil,
        }
      end

      def version
        "Metanorma::Jis #{Metanorma::Jis::VERSION}"
      end

      def use_presentation_xml(ext)
        return true if ext == :docx

        super
      end

      def output(xml, inname, outname, format, options = {})
        options_preprocess(options)
        case format
        when :html
          IsoDoc::Jis::HtmlConvert.new(options)
            .convert(inname, xml, nil, outname)
        when :docx
          ::IsoDoc::Jis::Docx::Adapter.new.convert(xml, outname)
        when :pdf
          IsoDoc::Jis::PdfConvert.new(options)
            .convert(inname, xml, nil, outname)
        when :presentation
          IsoDoc::Jis::PresentationXMLConvert.new(options)
            .convert(inname, xml, nil, outname)
        else
          super
        end
      end
    end
  end
end
