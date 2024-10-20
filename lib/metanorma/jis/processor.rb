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
          "STIX Two Math" => nil,
          "IPAexGothic" => nil,
          "IPAexMincho" => nil,
          "Courier New" => nil,
          "Cambria Math" => nil,
          "Times New Roman" => nil,
          "Arial" => nil,
          "Noto Serif" => nil,
          "Noto Serif HK" => nil,
          "Noto Serif JP" => nil,
          "Noto Serif JP ExtraLight" => nil,
          "Noto Serif JP Medium" => nil,
          "Noto Serif KR" => nil,
          "Noto Serif SC" => nil,
          "Noto Serif TC" => nil,
          "Noto Sans JP Thin" => nil,
          "Noto Sans Mono" => nil,
          "Noto Sans Mono CJK HK" => nil,
          "Noto Sans Mono CJK JP" => nil,
          "Noto Sans Mono CJK KR" => nil,
          "Noto Sans Mono CJK SC" => nil,
          "Noto Sans Mono CJK TC" => nil,
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
