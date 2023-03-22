require_relative "../../html2doc/lists"

module IsoDoc
  module JIS
    class WordConvert < IsoDoc::Iso::WordConvert
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
        move_to_inner_cover(docxml)
      end

      def move_to_inner_cover(docxml)
        source = docxml.at("//div[@type = 'inner-cover-note']")
        dest = docxml.at("//div[@id = 'boilerplate-inner-cover-note']")
        source && dest and dest.replace(source)
        source = docxml.at("//div[@type = 'contributors']")
        dest = docxml.at("//div[@id = 'boilerplate-contributors']")
        source && dest and dest.replace(source)
        docxml
      end

      def word_intro(docxml, level)
        intro = insert_toc(File.read(@wordintropage, encoding: "UTF-8"),
                           docxml, level)
        intro = populate_template(intro, :word)
        introxml = to_word_xhtml_fragment(intro)
        docxml.at('//div[@class="WordSection2"]') << introxml
          .to_xml(encoding: "US-ASCII")
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
        c = xml.at("//div[@class = 'WordSection2']")
        c.elements.first.at("./br") and c.elements.first.remove
        xml
      end

      STYLESMAP = {}.freeze

      def style_cleanup(docxml)
        new_styles(docxml)
        index_cleanup(docxml)
      end

      def new_styles(docxml)
        super
        biblio_paras(docxml)
        heading_to_para(docxml)
      end

      def biblio_paras(docxml)
        docxml.xpath("//div[@class = 'normref_div']//" \
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
    end
  end
end
