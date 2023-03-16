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
        { bodyfont: (options[:script] == "Jpan" ? '"MS Mincho",serif' : '"Times New Roman",serif'),
          headerfont: (options[:script] == "Jpan" ? '"MS Gothic",sans-serif' : '"Arial",sans-serif'),
          monospacefont: '"Courier New",monospace',
          normalfontsize: "10.0pt",
          monospacefontsize: "9.0pt",
          smallerfontsize: "10.0pt",
          footnotefontsize: "10.0pt" }
      end

      def default_file_locations(_options)
        { htmlstylesheet: html_doc_path("htmlstyle.scss"),
          htmlcoverpage: html_doc_path("html_jis_titlepage.html"),
          htmlintropage: html_doc_path("html_jis_intro.html"),
          wordstylesheet: html_doc_path("wordstyle.scss"),
          standardstylesheet: html_doc_path("isodoc.scss"),
          header: html_doc_path("header.html"),
          wordcoverpage: html_doc_path("word_jis_titlepage.html"),
          wordintropage: html_doc_path("word_jis_intro.html"),
          ulstyle: "l9",
          olstyle: "l8" }
      end

      def postprocess(result, filename, dir)
        filename = filename.sub(/\.doc$/, "")
        header = generate_header(filename, dir)
        result = from_xhtml(cleanup(to_xhtml(textcleanup(result))))
        toWord(result, filename, dir, header)
        @files_to_delete.each { |f| FileUtils.rm_f f }
      end

      def word_cleanup(docxml)
        word_note_cleanup(docxml)
        super
      end

      def word_note_cleanup(docxml)
        docxml.xpath("//p[@class = 'Note']").each do |p|
          p.xpath("//following-sibling:p").each do |p2|
            p2["class"] == "Note" and
              p2["class"] = "NoteCont"
          end
        end
      end

      def toWord(result, filename, dir, header)
        result = word_split(word_cleanup(to_xhtml(result)))
        @wordstylesheet = wordstylesheet_update
        result.each do |k, v|
          to_word1(v, "#{filename}#{k}", dir, header)
        end
        header&.unlink
        @wordstylesheet.unlink if @wordstylesheet.is_a?(Tempfile)
      end

      def to_word1(result, filename, dir, header)
        result or return
        result = from_xhtml(result).gsub(/-DOUBLE_HYPHEN_ESCAPE-/, "--")
        Html2Doc.new(
          filename: filename, imagedir: @localdir,
          stylesheet: @wordstylesheet&.path,
          header_file: header&.path, dir: dir,
          asciimathdelims: [@openmathdelim, @closemathdelim],
          liststyles: { ul: @ulstyle, ol: @olstyle }
        ).process(result)
      end

      def word_split(xml)
        b = xml.dup
        { _cover: cover_split(xml), "": main_split(b) }
      end

      def cover_split(xml)
        xml.at("//body").elements.each do |e|
          e.name == "div" && e["class"] == "WordSection1" and next
          e.remove
        end
        xml
      end

      def main_split(xml)
        c = xml.at("//div[@class = 'WordSection1']")
        c.next_element&.remove
        c.remove
        c = xml.at("//div[@class = 'bibliography']")
        c&.previous_element&.remove
        c&.remove
        xml
      end

      def bibliography(isoxml, out)
        (f = isoxml.at(ns(bibliography_xpath)) and f["hidden"] != "true") or
          return
        page_break(out)
        out.div class: "bibliography" do |div|
          div.h1 class: "Section3" do |h1|
            f.at(ns("./title"))&.children&.each { |c2| parse(c2, h1) }
          end
          biblio_list(f, div, true)
        end
      end

      include BaseConvert
      include Init
    end
  end
end
