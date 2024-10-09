require_relative "../../html2doc/lists"

module IsoDoc
  module Jis
    class WordConvert < IsoDoc::Iso::WordConvert
      def word_cleanup(docxml)
        word_note_cleanup(docxml)
        boldface(docxml)
        super
      end

      def word_remove_empty_sections(docxml)
        move_to_inner_cover(docxml) # preempt by populating WordSection1
        super
      end

      def move_to_inner_cover(docxml)
        source = docxml.at("//div[@type = 'inner-cover-note']")
        dest = docxml.at("//div[@id = 'boilerplate-inner-cover-note']")
        source && dest and dest.replace(source.remove)
        source = docxml.at("//div[@type = 'participants']")
        dest = docxml.at("//div[@id = 'boilerplate-contributors']")
        source && dest and dest.replace(source.remove)
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
        docxml.xpath("//b").each do |b|
          b.name = "span"
          b["class"] = "Strong"
        end
      end

      def postprocess_cleanup(result)
        result = cleanup(to_xhtml(textcleanup(result)))
        word_split(word_cleanup(result))
      end

      def toWord(result, filename, dir, header)
        result.each do |k, v|
          to_word1(v, "#{filename}#{k}", dir, header)
        end
        header&.unlink
        @wordstylesheet.unlink if @wordstylesheet.is_a?(Tempfile)
      end

      def to_word1(result, filename, dir, header)
        result or return
        result = from_xhtml(result).gsub(/-DOUBLE_HYPHEN_ESCAPE-/, "--")
        ::Html2Doc::Jis.new(
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
        if c = xml.at("//div[@class = 'WordSection1']")
          c.next_element&.remove
          c.remove
        end
        if c = xml.at("//div[@class = 'WordSection2']")
          c.elements.first.at("./br") and c.elements.first.remove
        end
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
          p.parent.xpath("./p[not(@class) or @class = 'MsoNormal']").each do |n|
            n["class"] = "ForewordText"
          end
        end
        docxml.xpath("//h1[@class = 'IntroTitle'] | //h1[@class = 'Annex'] | " \
                     "//h2[@class = 'Terms'] | " \
                     "//h3[@class = 'Terms'] | //h4[@class = 'Terms'] | " \
                     "//h5[@class = 'Terms'] | //h6[@class = 'Terms']").each do |n|
          n.name = "p"
        end
      end

      def word_annex_cleanup1(docxml, lvl)
        docxml.xpath("//h#{lvl}[ancestor::*[@class = 'Section3']]").each do |h2|
          h2.name = "p"
          h2["class"] = "h#{lvl}Annex"
        end
      end
    end
  end
end
