require_relative "base_convert"
require "isodoc"
require_relative "init"

module IsoDoc
  module JIS
    class WordConvert < IsoDoc::WordConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def default_fonts(options)
        { bodyfont: (options[:script] == "Hans" ? '"Source Han Sans",serif' : '"Gesta","Tahoma",sans-serif'),
          headerfont: (options[:script] == "Hans" ? '"Source Han Sans",sans-serif' : '"Gesta","Tahoma",sans-serif'),
          monospacefont: '"Courier New",monospace',
          normalfontsize: "11.0pt",
          monospacefontsize: "9.0pt",
          smallerfontsize: "10.0pt",
          footnotefontsize: "10.0pt" }
      end

      def default_file_locations(options)
        { htmlstylesheet: html_doc_path("htmlstyle.scss"),
          htmlcoverpage: html_doc_path("html_jis_titlepage.html"),
          htmlintropage: html_doc_path("html_jis_intro.html"),
          wordstylesheet: html_doc_path("wordstyle.scss"),
          standardstylesheet: html_doc_path("isodoc.scss"),
          header: html_doc_path("header.html"),
          wordcoverpage: html_doc_path("word_jis_titlepage.html"),
          wordintropage: html_doc_path("word_jis_intro.html"),
          ulstyle: "l3",
          olstyle: "l2" }
      end

      include BaseConvert
      include Init
    end
  end
end
