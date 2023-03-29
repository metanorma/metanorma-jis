require_relative "base_convert"
require "isodoc"
require_relative "init"
require_relative "word_cleanup"
require_relative "figure"

module IsoDoc
  module JIS
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

      def norm_ref(isoxml, out, num)
        (f = isoxml.at(ns(norm_ref_xpath)) and f["hidden"] != "true") or
          return num
        out.div class: "normref_div" do |div|
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

      def preface(isoxml, out)
        isoxml.xpath(ns("//preface/clause | //preface/references | " \
                        "//preface/definitions | //preface/terms")).each do |f|
          out.div **attr_code(class: "Section3", id: f["id"],
                              type: f["type"]) do |div|
            clause_name(f, f&.at(ns("./title")), div, { class: "IntroTitle" })
            f.elements.each do |e|
              parse(e, div) unless e.name == "title"
            end
          end
        end
      end

      def introduction(isoxml, out)
        f = isoxml.at(ns("//introduction")) || return
        out.div class: "Section3", id: f["id"] do |div|
          clause_name(f, f.at(ns("./title")), div, { class: "IntroTitle" })
          f.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def make_body2(body, docxml)
        body.div class: "WordSection2" do |div2|
          boilerplate docxml, div2
          preface_block docxml, div2
          abstract docxml, div2
          foreword docxml, div2
          preface docxml, div2
          acknowledgements docxml, div2
          div2.p { |p| p << "&#xa0;" } # placeholder
        end
        section_break(body)
      end

      def middle(isoxml, out)
        middle_title(isoxml, out)
        middle_admonitions(isoxml, out)
        introduction isoxml, out
        scope isoxml, out, 0
        norm_ref isoxml, out, 0
        terms_defs isoxml, out, 0
        symbols_abbrevs isoxml, out, 0
        clause isoxml, out
        annex isoxml, out
        bibliography isoxml, out
        # colophon isoxml, out
      end

      def footnote_parse(node, out)
        return table_footnote_parse(node, out) if @in_table || @in_figure # &&

        # !node.ancestors.map(&:name).include?("name")

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

      def make_table_footnote_target(out, fnid, fnref)
        attrs = { id: fnid, class: "TableFootnoteRef" }
        out.span do |s|
          s << @i18n.table_footnote
          out.span **attrs do |a|
            a << "#{fnref})"
          end
          insert_tab(s, 1)
        end
      end

      def table_title_parse(node, out); end

      def table_attrs(node)
        { id: node["id"], title: node["alt"],
          summary: node["summary"], width: node["width"],
          class: (node.text.length > 4000 ? "MsoTableGridBig" : "MsoTableGrid"),
          style: "border-collapse:collapse;" \
                 "mso-table-anchor-horizontal:column;mso-table-overlap:never;" \
                 "border:none;mso-padding-alt: " \
                 "0cm 5.4pt 0cm 5.4pt;mso-border-insideh:none;" \
                 "mso-border-insidev:none;#{keep_style(node)}",
          border: 0, cellspacing: 0, cellpadding: 0 }
      end

      def make_tr_attr_style(cell, row, rowmax, totalrows, opt)
        top = row.zero? ? "#{SW1} 1.5pt;" : "none;"
        bottom = "#{SW1} #{rowmax >= totalrows ? '1.5' : '1.0'}pt;"
        ret = <<~STYLE.gsub(/\n/, "")
          border-top:#{top}mso-border-top-alt:#{top}
          border-left:#{bottom}mso-border-top-alt:#{bottom}
          border-right:#{bottom}mso-border-top-alt:#{bottom}
          border-bottom:#{bottom}mso-border-bottom-alt:#{bottom}
        STYLE
        opt[:bordered] or ret = ""
        pb = keep_rows_together(cell, rowmax, totalrows, opt) ? "avoid" : "auto"
        "#{ret}page-break-after:#{pb};"
      end

      def new_fullcolspan_row(table, tfoot)
        # how many columns in the table?
        cols = 0
        table.at(".//tr").xpath("./td | ./th").each do |td|
          cols += (td["colspan"] ? td["colspan"].to_i : 1)
        end
        style = "border-top:0pt;mso-border-top-alt:0pt;" \
                "border-bottom:#{SW1} 1.5pt;mso-border-bottom-alt:#{SW1} 1.5pt;" \
                "border-left:#{SW1} 1.5pt;mso-border-left-alt:#{SW1} 1.5pt;" \
                "border-right:#{SW1} 1.5pt;mso-border-right-alt:#{SW1} 1.5pt;"
        tfoot.add_child("<tr><td colspan='#{cols}' style='#{style}'/></tr>")
        tfoot.xpath(".//td").last
      end

      include BaseConvert
      include Init
    end
  end
end
