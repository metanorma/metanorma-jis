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

      def make_preface(docxml)
        docxml.at(ns("//preface")) ||
          docxml.at(ns("//sections | //annex | //bibliography"))
            &.before("<preface> </preface>")
            &.previous_element
      end

      def toc_title_insert_pt(docxml)
        ins = make_preface(docxml) or return nil
        ins.children.last.after(" ").next
      end

      def preface_rearrange(doc)
        move_introduction(doc)
        super
        move_participants(doc)
      end

      def move_introduction(doc)
        source = doc.at(ns("//preface/introduction")) or return
        dest = doc.at(ns("//sections")) ||
          doc.at(ns("//preface")).after("<sections> </sections>").next_element
        dest.children.empty? and dest.children = " "
        dest.children.first.next = source
      end

      def move_participants(doc)
        p = doc.at(ns("//clause[@type = 'participants']")) or return
        t = participant_table(p) or return
        p.remove
        ins = make_preface(doc) or return nil
        ins.children.first.previous = t
      end

      def participant_table(clause)
        s = clause.at(ns("./sourcecode")) or return nil
        y = YAML.safe_load(s.children.to_xml(encoding: "UTF-8")) or return nil
        y.is_a?(Array) or return nil
        out1 = <<~OUTPUT
          <clause id='_#{UUIDTools::UUID.random_create}'><title>#{@meta.get[:"investigative-committee"]} #{@i18n.membership_table}</title>
          <table unnumbered='true'>
          <thead>
          <tr><th/><th>#{@i18n.full_name}</th><th>#{@i18n.affiliation}</th></tr>
          </thead>
          <tbody>
        OUTPUT
        out2 = <<~OUTPUT
          </tbody></table></clause>
        OUTPUT
        "#{out1}#{participant_rows(y)}#{out2}"
      end

      def participant_rows(yaml)
        yaml.map do |y|
          r = y["role"] ? @i18n.l10n("(#{y['role']})") : ""
          n = y["name"]
          if n.is_a?(Hash)
            n =
              if @lang == "ja" then "#{n['surname']} #{n['givenname']}"
              else "#{n['givenname']} #{n['surname']}" end
          end
          "<tr><td>#{r}</rd><td>#{n}</td><td>#{y['affiliation']}</td></tr>"
        end.join("\n")
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
