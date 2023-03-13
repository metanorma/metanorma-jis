require "metanorma/processor"

module Metanorma
  module JIS
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
          doc: "doc",
        )
      end

      def fonts_manifest
        {
          "Tahoma" => nil,
          "STIX Two Math" => nil,
          "Source Han Sans" => nil,
          "Source Han Sans Normal" => nil,
          "Courier New" => nil,
          "BSI Gesta" => nil,
          "Cambria" => nil,
          "Cambria Math" => nil,
          "Times New Roman" => nil,
          "Open Sans" => nil,
        }
      end

      def version
        "Metanorma::JIS #{Metanorma::JIS::VERSION}"
      end

      def output(xml, inname, outname, format, options = {})
        case format
        when :html
          IsoDoc::JIS::HtmlConvert.new(options).convert(inname, xml, nil, outname)
        when :doc
          IsoDoc::JIS::WordConvert.new(options).convert(inname, xml, nil, outname)
        when :pdf
          IsoDoc::JIS::PdfConvert.new(options).convert(inname, xml, nil, outname)
        when :presentation
          IsoDoc::JIS::PresentationXMLConvert.new(options).convert(inname, xml, nil, outname)
        else
          super
        end
      end
    end
  end
end
