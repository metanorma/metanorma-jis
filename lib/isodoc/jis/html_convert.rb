require "isodoc"
require "metanorma-iso"
require_relative "base_convert"
require_relative "init"

module IsoDoc
  module JIS
    class HtmlConvert < IsoDoc::Iso::HtmlConvert
      def initialize(options)
        super
        @libdir = File.dirname(__FILE__)
      end

      # TODO : true font is BSI Gesta, which is a webfont
      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"Source Han Sans",serif' : '"Gesta","Tahoma",sans-serif'),
          headerfont: (options[:script] == "Hans" ? '"Source Han Sans",sans-serif' : '"Gesta","Tahoma",sans-serif'),
          monospacefont: '"Courier New",monospace',
          monospacefontsize: "1.0em",
          footnotefontsize: "0.9em",
        }
      end

      def default_file_locations(_options)
        @libdir = File.dirname(__FILE__)
        {
          htmlstylesheet: html_doc_path("htmlstyle.scss"),
          htmlcoverpage: html_doc_path("html_jis_titlepage.html"),
          htmlintropage: html_doc_path("html_jis_intro.html"),
        }
      end

      include BaseConvert
      include Init
    end
  end
end
