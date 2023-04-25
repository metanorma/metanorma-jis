require "isodoc"
require "metanorma-iso"

module IsoDoc
  module JIS
    module BaseConvert
      def middle_title(_isoxml, out)
        middle_title_hdr(out)
        middle_title_main(out, "zzSTDTitle1")
        middle_subtitle_main(out)
        # middle_title_amd(out)
      end

      def middle_title_hdr(out)
        out.p(class: "JapaneseIndustrialStandard") do |p|
          p << @i18n.jis
          @meta.get[:unpublished] and p << @i18n.l10n("(#{@i18n.draft_label})")
          insert_tab(p, 7)
          p << "<span class='JIS'>JIS</span>"
        end
        out.p(class: "StandardNumber") do |p|
          insert_tab(p, 1)
          p << @meta.get[:docnumber_undated]
          if yr = @meta.get[:docyear]
            p << ": "
            p << "<span class='EffectiveYear'>#{yr}</span>"
          end
        end
        out.p(class: "IDT")
      end

      def middle_title_main(out, style)
        out.p(class: style) do |p|
          p << @meta.get[:doctitleintro]
          p << " &#x2014; " if @meta.get[:doctitleintro] && @meta.get[:doctitlemain]
          p << @meta.get[:doctitlemain]
          p << " &#x2014; " if @meta.get[:doctitlemain] && @meta.get[:doctitlepart]
        end
        a = @meta.get[:doctitlepart] and out.p(class: "zzSTDTitle1") do |p|
          b = @meta.get[:doctitlepartlabel] and p << "#{b}: "
          p << "<br/><b>#{a}</b>"
        end
      end

      def middle_subtitle_main(out)
        @meta.get[:docsubtitlemain] or return
        out.p(class: "zzSTDTitle2") do |p|
          p << @meta.get[:docsubtitleintro]
          p << " &#x2014; " if @meta.get[:docsubtitleintro] && @meta.get[:docsubtitlemain]
          p << @meta.get[:docsubtitlemain]
          p << " &#x2014; " if @meta.get[:docsubtitlemain] && @meta.get[:docsubtitlepart]
        end
        a = @meta.get[:docsubtitlepart] and out.p(class: "zzSTDTitle2") do |p|
          b = @meta.get[:docsubtitlepartlabel] and p << "#{b}: "
          p << "<br/><b>#{a}</b>"
        end
      end

      def commentary_title(_isoxml, out)
        commentary_title_hdr(out)
        middle_title_main(out, "CommentaryStandardName")
      end

      def commentary_title_hdr(out)
        out.p(class: "CommentaryStandardNumber") do |p|
          p << "JIS #{@meta.get[:docnumber_undated]}"
          if yr = @meta.get[:docyear]
            p << ": "
            p << "<span class='CommentaryEffectiveYear'>#{yr}</span>"
          end
        end
      end

      def termnote_parse(node, out)
        name = node.at(ns("./name"))&.remove
        out.div **note_attrs(node) do |div|
          div.p do |p|
            if name
              p.span class: "note_label" do |s|
                name.children.each { |n| parse(n, s) }
              end
              p << termnote_delim
            end
            para_then_remainder(node.first_element_child, node, p, div)
          end
        end
      end

      def admonition_name_parse(_node, div, name)
        div.span class: "note_label" do |s|
          name.children.each { |n| parse(n, s) }
          s << " &#x2014; "
        end
      end

      def para_class(node)
        super || node["class"]
      end

      def make_tr_attr(cell, row, totalrows, header, bordered)
        cell["border"] == "0" and bordered = false
        super
      end

      def middle(isoxml, out)
        middle_title(isoxml, out)
        middle_admonitions(isoxml, out)
        i = isoxml.at(ns("//sections/introduction")) and
          introduction i, out
        scope isoxml, out, 0
        norm_ref isoxml, out, 0
        clause_etc isoxml, out, 0
        annex isoxml, out
        bibliography isoxml, out
        commentary isoxml, out
        indexsect isoxml, out
      end

      def annex(isoxml, out)
        amd(isoxml) and @suppressheadingnumbers = @oldsuppressheadingnumbers
        isoxml.xpath(ns("//annex[not(@commentary = 'true')]")).each do |c|
          page_break(out)
          out.div **attr_code(annex_attrs(c)) do |s|
            c.elements.each do |c1|
              if c1.name == "title" then annex_name(c, c1, s)
              else parse(c1, s)
              end
            end
          end
        end
        amd(isoxml) and @suppressheadingnumbers = true
      end

      def commentary(isoxml, out)
        isoxml.xpath(ns("//annex[@commentary = 'true']")).each do |c|
          page_break(out)
          out.div **attr_code(annex_attrs(c)) do |s|
            c.elements.each do |c1|
              if c1.name == "title" then annex_name(c, c1, s)
              else parse(c1, s)
              end
            end
          end
        end
      end
    end
  end
end
