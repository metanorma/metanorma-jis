require_relative "../../html2doc/lists"
require_relative "base_convert"
require "isodoc"
require_relative "init"

module IsoDoc
  module JIS
    class WordConvert < IsoDoc::Iso::WordConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def convert(input_filename, file = nil, debug = false,
                output_filename = nil)
        file = File.read(input_filename, encoding: "utf-8") if file.nil?
        @openmathdelim, @closemathdelim = extract_delims(file)
        docxml, filename, dir = convert_init(file, input_filename, debug)
        result = convert1(docxml, filename, dir)
        return result if debug

        output_filename ||= "#{filename}.#{@suffix}"
        postprocess(result, output_filename, dir)
        FileUtils.rm_rf dir
      end

      def convert1(docxml, filename, dir)
        @options.merge!(default_fonts({})) # updated @script
        super
      end

      def default_fonts(_options)
        { bodyfont: (@script == "Jpan" ? '"MS Mincho",serif' : '"Times New Roman",serif'),
          headerfont: (@script == "Jpan" ? '"MS Gothic",sans-serif' : '"Arial",sans-serif'),
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
        boldface(docxml)
        super
      end

      def word_note_cleanup(docxml)
        docxml.xpath("//p[@class = 'Note']").each do |p|
          p.xpath("//following-sibling::p").each do |p2|
            p2["class"] == "Note" and
              p2["class"] = "NoteCont"
          end
        end
      end

      def boldface(docxml)
        docxml.xpath("//h1 | h2 | h3 | h4 | h5 | h6").each do |h|
          h.children = "<b>#{to_xml(h.children)}</b>"
        end
        docxml.xpath("//b").each do |b|
          b.name = "span"
          b["class"] = "Strong"
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
        ::Html2Doc::JIS.new(
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
        xml
      end

      def norm_ref(isoxml, out, num)
        (f = isoxml.at(ns(norm_ref_xpath)) and f["hidden"] != "true") or
          return num
        out.div class: "normref" do |div|
          num += 1
          clause_name(f, f.at(ns("./title")), div, nil)
          if f.name == "clause"
            f.elements.each { |e| parse(e, div) unless e.name == "title" }
          else biblio_list(f, div, false)
          end
        end
        num
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

      def annex_name(_annex, name, div)
        preceding_floating_titles(name, div)
        return if name.nil?

        div.h1 class: "Annex" do |t|
          name.children.each { |c2| parse(c2, t) }
          clause_parse_subtitle(name, t)
        end
      end

      def new_styles(docxml)
        super
        biblio_paras(docxml)
        heading_to_para(docxml)
      end

      def biblio_paras(docxml)
        docxml.xpath("//div[@class = 'normref']//" \
                     "p[not(@class) or @class = 'MsoNormal']").each do |p|
          p["class"] = "NormRefText"
        end
      end

      def heading_to_para(docxml)
        docxml.xpath("//h1[@class = 'ForewordTitle']").each do |p|
          p.name = "p"
          p.xpath("../div/p[not(@class) or @class = 'MsoNormal']").each do |n|
            n["class"] = "ForewordText"
          end
        end
      end

      include BaseConvert
      include Init
    end
  end
end
