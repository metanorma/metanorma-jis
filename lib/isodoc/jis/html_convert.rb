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

      def convert1(docxml, filename, dir)
        @options.merge!(default_fonts({})) # updated @script
        super
      end

      def default_fonts(_options)
        {
          bodyfont: (@script == "Jpan" ? '"MS Mincho",serif' : '"Times New Roman",serif'),
          headerfont: (@script == "Jpan" ? '"MS Gothic",sans-serif' : '"Arial",sans-serif'),
          monospacefont: '"Courier New",monospace',
          monospacefontsize: "1.0em",
          footnotefontsize: "0.9em",
        }
      end

      def default_file_locations(_options)
        @libdir = File.dirname(__FILE__)
        {
          htmlstylesheet: html_doc_path("style-iso.scss"),
          htmlcoverpage: html_doc_path("html_jis_titlepage.html"),
          htmlintropage: html_doc_path("html_jis_intro.html"),
        }
      end

      include BaseConvert
      include Init
    end
  end
end
