require_relative "base_convert"
require "isodoc"
require_relative "init"
require_relative "word_cleanup"
require_relative "figure"
require_relative "table"

module IsoDoc
  module Jis
    class WordConvert < IsoDoc::Iso::WordConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
        @libdir = File.dirname(__FILE__)
      end

      def init_dis(opt); end

      def clause_attrs(node)
        # capture the type of clause
        { id: node["id"], type: node["type"] }
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
        @libdir = File.dirname(__FILE__)
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

      def norm_ref(node, out)
        node["hidden"] != "true" or return
        out.div class: "normref_div" do |div|
          clause_name(node, node.at(ns("./fmt-title")), div, nil)
          if node.name == "clause"
            node.elements.each { |e| parse(e, div) unless e.name == "fmt-title" }
          else biblio_list(node, div, false)
          end
        end
      end

      def bibliography(node, out)
        node["hidden"] != "true" or return
        page_break(out)
        out.div class: "bibliography" do |div|
          div.h1 class: "Section3" do |h1|
            node.at(ns("./fmt-title"))&.children&.each { |c2| parse(c2, h1) }
          end
          biblio_list(node, div, true)
        end
      end

      def annex_name(_annex, name, div)
        return if name.nil?

        div.h1 class: "Annex" do |t|
          name.children.each { |c2| parse(c2, t) }
          clause_parse_subtitle(name, t)
        end
      end

      def preface_attrs(node)
        { id: node["id"], type: node["type"],
          class: node["type"] == "toc" ? "TOC" : "Section3" }
      end

      def introduction(clause, out)
        out.div class: "Section3", id: clause["id"] do |div|
          clause_name(clause, clause.at(ns("./fmt-title")), div,
                      { class: "IntroTitle" })
          clause.elements.each do |e|
            parse(e, div) unless e.name == "fmt-title"
          end
        end
      end

      # KILL
      def footnote_parsex(node, out)
        return table_footnote_parse(node, out) if @in_table || @in_figure # &&

        fn = node["reference"] || UUIDTools::UUID.random_create.to_s
        return seen_footnote_parse(node, out, fn) if @seen_footnote.include?(fn)

        @fn_bookmarks[fn] = bookmarkid
        out.span style: "mso-bookmark:_Ref#{@fn_bookmarks[fn]}" do |s|
          s.a class: "FootnoteRef", "epub:type": "footnote",
              href: "#ftn#{fn}" do |a|
            a.sup { |sup| sup << fn }
          end
        end
        @in_footnote = true
        @footnotes << make_generic_footnote_text(node, fn)
        @in_footnote = false
        @seen_footnote << fn
      end

      def annex(node, out)
        node["commentary"] == "true" and return commentary(node, out)
        amd?(node.document.root) and
          @suppressheadingnumbers = @oldsuppressheadingnumbers
        page_break(out)
        render_annex(out, node)
        amd?(node.document.root) and @suppressheadingnumbers = true
      end

      def commentary(node, out)
        out.span style: "mso-bookmark:PRECOMMENTARYPAGEREF"
        section_break(out)
        out.div class: "WordSectionCommentary" do |div|
          render_annex(div, node)
        end
      end

      def render_annex(out, clause)
        out.div **attr_code(annex_attrs(clause)) do |s|
          clause.elements.each do |c1|
            if c1.name == "fmt-title" then annex_name(clause, c1, s)
            else parse(c1, s)
            end
          end
        end
      end

      include BaseConvert
      include Init
    end
  end
end
