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
          doc: "doc",
        )
      end

      def fonts_manifest
        {
          "STIX Two Math" => nil,
          "IPAexGothic" => nil,
          "IPAexMincho" => nil,
          "Noto Serif JP" => nil,
          "Noto Serif JP ExtraLight" => nil,
          "Noto Serif JP Medium" => nil,
          "Noto Serif JP Black" => nil,
          "Noto Sans JP Thin" => nil,
          "Noto Sans JP Medium" => nil,
          "Courier New" => nil,
          "Cambria Math" => nil,
          "Times New Roman" => nil,
          "Arial" => nil,
        }
      end

      def version
        "Metanorma::Jis #{Metanorma::Jis::VERSION}"
      end

      def output(xml, inname, outname, format, options = {})
        options_preprocess(options)
        case format
        when :html
          IsoDoc::Jis::HtmlConvert.new(options).convert(inname, xml, nil, outname)
        when :doc
          IsoDoc::Jis::WordConvert.new(options).convert(inname, xml, nil, outname)
        when :pdf
          IsoDoc::Jis::PdfConvert.new(options).convert(inname, xml, nil, outname)
        when :presentation
          IsoDoc::Jis::PresentationXMLConvert.new(options).convert(inname, xml, nil, outname)
        else
          super
        end
      end
    end
  end
end
