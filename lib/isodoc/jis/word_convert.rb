require_relative "base_convert"
require "isodoc"
require_relative "init"
require_relative "word_cleanup"

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
        colophon isoxml, out
      end

      def figure_attrs(node)
        attr_code(id: node["id"], class: "MsoTableGrid",
                  style: "border-collapse:collapse;" \
                         "border:none;mso-padding-alt: " \
                         "0cm 5.4pt 0cm 5.4pt;mso-border-insideh:none;" \
                         "mso-border-insidev:none;#{keep_style(node)}",
                  border: 0, cellspacing: 0, cellpadding: 0)
      end

      def figure_components(node)
        { units: node.at(ns("./note[@type = 'units']/p")),
          notes: node.xpath(ns("./note[not(@type = 'units')]")),
          name: node.at(ns("./name")),
          key: node.at(ns("./dl")),
          img: node.at(ns("./image")),
          subfigs: node.xpath(ns("./figure")).map { |n| figure_components(n) } }
      end

      def figure_parse1(node, out)
        c = figure_components(node)
        out.table **figure_attrs(node) do |div|
          %i(units img subfigs key notes name).each do |key|
            if key == :subfigs
              c[key].each do |n|
                n[:subname] = n[:name]
                figure_row(node, div, n, :img)
                figure_row(node, div, n, :subname)
              end
            else figure_row(node, div, c, key)
            end
          end
        end
      end

      def figure_name_parse(_node, div, name)
        name.nil? and return
        div.p class: "Tabletitle", style: "text-align:center;" do |p|
          name.children.each { |n| parse(n, p) }
        end
      end

      def figure_row(node, table, hash, key)
        hash[key].nil? || (hash[key].is_a?(Array) && hash[key].empty?) and
          return
        table.tr do |r|
          r.td valign: "top", style: "padding:0cm 5.4pt 0cm 5.4pt" do |d|
            figure_row1(node, d, hash, key)
          end
        end
      end

      def fig_para(klass, row, nodes)
        row.td valign: "top", style: "padding:0cm 5.4pt 0cm 5.4pt" do |d|
          d.p class: klass do |p|
            nodes.each { |n| parse(n, p) }
          end
        end
      end

      def figure_row1(node, cell, hash, key)
        case key
        when :units
          cell.p class: "UnitStatement" do |p|
            hash[key].children.each { |n| parse(n, p) }
          end
        when :key
          figure_key(cell)
          parse(hash[key], cell)
        when :notes then hash[key].each { |n| parse(n, cell) }
        when :name then figure_name_parse(node, cell, hash[key])
        when :img
          cell.p class: "FFFF" do |p|
            parse(hash[key], p)
          end
        when :subname
          cell.p class: "SubfigureCaption" do |p|
            hash[key].children.each { |n| parse(n, p) }
          end
        end
      end

      def dl_parse(node, out)
        node.ancestors("table, dl, figure").empty? or
          return ::IsoDoc::Convert.instance_method(:dl_parse).bind(self)
              .call(node, out)
        dl_parse_table(node, out)
      end

      include BaseConvert
      include Init
    end
  end
end
