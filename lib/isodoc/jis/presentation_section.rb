require_relative "init"
require "isodoc"

module IsoDoc
  module Jis
    class PresentationXMLConvert < IsoDoc::Iso::PresentationXMLConvert
      def annex1(elem)
        elem["commentary"] == "true" and return commentary(elem)
        lbl = @xrefs.anchor(elem["id"], :label)
        if t = elem.at(ns("./title"))
          t.children = "<strong>#{to_xml(t.children)}</strong>"
        end
        prefix_name(elem, { caption: "<br/>" }, lbl, "title")
      end

      def annex(docxml)
        super
        move_commentaries_to_end(docxml)
      end

      def move_commentaries_to_end(docxml)
        docxml.at(ns("//annex[@commentary = 'true']")) or return
        b = docxml.at(ns("//bibliography")) ||
          docxml.at(ns("//annex[last()]")).after(" ").next
        docxml.xpath(ns("//annex[@commentary = 'true']")).reverse_each do |x|
          b.next = x.remove
        end
      end

      def commentary(elem)
        t = elem.elements.first
        commentary_title_hdr(t)
        middle_title_main(t, "CommentaryStandardName")
        prefix_name(elem, {}, nil, "title")
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
        dest.add_first_child source
      end

      def move_participants(doc)
        doc.xpath(ns("//clause[@type = 'participants']")).reverse_each do |p|
          t = participant_table(p) or next
          p.remove
          ins = make_preface(doc) or next
          ins.add_first_child t
        end
      end

      def participant_table(clause)
        s, t, y, d = participant_table_prep(clause)
        s or return nil
        out1 = <<~OUTPUT
          <clause #{add_id_text} type="participants"><title>#{t}</title>
          <table #{add_id_text} unnumbered='true'>
          <thead>
          <tr #{add_id_text}><th #{add_id_text}/><th #{add_id_text}>#{@i18n.full_name}</th><th #{add_id_text}>#{@i18n.affiliation}</th></tr>
          </thead>
          <tbody>
        OUTPUT
        out2 = <<~OUTPUT
          </tbody>#{d&.to_xml}</table></clause>
        OUTPUT
        "#{out1}#{participant_rows(y)}#{out2}"
      end

      def participant_table_prep(clause)
        s = clause.at(ns("./sourcecode"))
        t = clause.at(ns("./title"))&.children&.to_xml ||
          %(#{@meta.get[:"investigative-committee"]} #{@i18n.membership_table})
        y = YAML.safe_load(s.children.to_xml(encoding: "UTF-8"))
        d = clause.at(ns("./dl[@key = 'true']"))
        s && y.is_a?(Array) or return [nil, nil, nil, nil]
        [s, t, y, d]
      end

      def participant_rows(yaml)
        yaml.map do |y|
          r = y["role"] ? @i18n.l10n("(#{y['role']})") : ""
          n = y["name"]
          if n.is_a?(Hash)
            n = if @lang == "ja" then "#{n['surname']} #{n['givenname']}"
                else "#{n['givenname']} #{n['surname']}" end
          end
          <<~XML
            <tr #{add_id_text}><td #{add_id_text}>#{r}</td><td #{add_id_text}>#{n}</td><td #{add_id_text}>#{y['affiliation']}</td></tr>
          XML
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
