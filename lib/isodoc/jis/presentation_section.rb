require_relative "init"
require "isodoc"

module IsoDoc
  module JIS
    class PresentationXMLConvert < IsoDoc::Iso::PresentationXMLConvert
      def annex1(elem)
        elem["commentary"] == "true" and return commentary(elem)
        lbl = @xrefs.anchor(elem["id"], :label)
        if t = elem.at(ns("./title"))
          t.children = "<strong>#{to_xml(t.children)}</strong>"
        end
        prefix_name(elem, "<br/>", lbl, "title")
      end

      def annex(docxml)
        super
        move_commentaries_to_end(docxml)
      end

      def move_commentaries_to_end(docxml)
        docxml.at(ns("//annex[@commentary = 'true']")) or return
        b = docxml.at(ns("//bibliography")) ||
          docxml.at(ns("//annex[last()]")).after(" ").next
        docxml.xpath(ns("//annex[@commentary = 'true']")).reverse.each do |x|
          b.next = x.remove
        end
      end

      def commentary(elem)
        t = elem.elements.first
        commentary_title_hdr(t)
        middle_title_main(t, "CommentaryStandardName")
      end

      def commentary_title_hdr(elem)
        ret = <<~COMMENTARY
          <p class="CommentaryStandardNumber">JIS #{@meta.get[:docnumber_undated]}
        COMMENTARY
        yr = @meta.get[:docyear] and
          ret += ": <span class='CommentaryEffectiveYear'>#{yr}</span>"
        elem.previous = ret
      end

      def toc_title_insert_pt(docxml)
        ins = docxml.at(ns("//preface")) ||
          docxml.at(ns("//sections | //annex | //bibliography"))
            &.before("<preface> </preface>")
            &.previous_element or return nil
        ins.children.last.after(" ").next
      end

      def preface_rearrange(doc)
        move_introduction(doc)
        super
      end

      def move_introduction(doc)
        source = doc.at(ns("//preface/introduction")) or return
        dest = doc.at(ns("//sections")) ||
          doc.at(ns("//preface")).after("<sections> </sections>").next_element
        dest.children.empty? and dest.children = " "
        dest.children.first.next = source
      end

      def middle_title(docxml)
        s = docxml.at(ns("//sections")) or return
        elem = s.children.first
        middle_title_hdr(elem)
        middle_title_main(elem, "zzSTDTitle1")
        middle_subtitle_main(elem, "zzSTDTitle2")
        # middle_title_amd(s.children.first)
      end

      def middle_title_hdr(out)
        ret = "<p class='JapaneseIndustrialStandard'>#{@i18n.jis}"
        @meta.get[:unpublished] and ret += @i18n.l10n("(#{@i18n.draft_label})")
        ret += ("<tab/>" * 7)
        ret += "<span class='JIS'>JIS</span></p>"
        ret += "<p class='StandardNumber'><tab/>#{@meta.get[:docnumber_undated]}"
        if yr = @meta.get[:docyear]
          ret += ": <span class='EffectiveYear'>#{yr}</span>"
        end
        ret += "</p><p class='IDT'/>"
        out.previous = ret
      end

      def middle_title_main(out, style)
        t = @meta.get[:doctitlemain]
        (t && !t.empty?) or return
        ret =
          middle_title_para(style, :doctitleintro, :doctitlemain, :doctitlepart)
        if a = @meta.get[:doctitlepart]
          ret += "<p class='zzSTDTitle1'>"
          b = @meta.get[:doctitlepartlabel] and ret += "#{b}: "
          ret += "<br/><strong>#{a}</strong></p>"
        end
        out.previous = ret
      end

      def middle_subtitle_main(out, style)
        t = @meta.get[:docsubtitlemain]
        (t && !t.empty?) or return
        ret = middle_title_para(style, :docsubtitleintro, :docsubtitlemain,
                                :docsubtitlepart)
        if a = @meta.get[:docsubtitlepart]
          ret += "<p class='zzSTDTitle2'>"
          b = @meta.get[:docsubtitlepartlabel] and ret += "#{b}: "
          ret += "<br/><strong>#{a}</strong></p>"
        end
        out.previous = ret
      end

      def middle_title_para(style, intro, main, part)
        ret = "<p class='#{style}'>#{@meta.get[intro]}"
        ret += " &#x2014; " if @meta.get[intro] && @meta.get[main]
        ret += @meta.get[main]
        ret += " &#x2014; " if @meta.get[main] && @meta.get[part]
        ret += "</p>"
        ret
      end
    end
  end
end
