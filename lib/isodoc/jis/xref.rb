module IsoDoc
  module JIS
    class Counter < IsoDoc::XrefGen::Counter
      def ol_type(list, depth)
        return list["type"].to_sym if list["type"]
        return :alphabet if depth == 1

        :arabic
      end

      def listlabel(_list, depth)
        case depth
        when 1 then (96 + @num).chr.to_s
        else @num.to_s
        end
      end
    end

    class Xref < IsoDoc::Iso::Xref
      def hierfigsep
        @lang == "ja" ? "の" : super
      end

      def subfigure_label(subfignum)
        subfignum.zero? and return ""
        sep = @lang == "ja" ? "の" : " "
        "#{sep}#{(subfignum + 96).chr})"
      end

      def annex_name_lbl(clause, num)
        obl = l10n("(#{@labels['inform_annex']})")
        clause["obligation"] == "normative" and
          obl = l10n("(#{@labels['norm_annex']})")
        title = Common::case_with_markup(@labels["annex"], "capital",
                                         @script)
        l10n("#{title} #{num}<br/>#{obl}")
      end

      def annex_name_anchors1(clause, num, level)
        @anchors[clause["id"]] =
          { xref: num, label: num, level: level,
            subtype: "annex" }
      end

      def annex_names1(clause, num, level)
        annex_name_anchors1(clause, num, level)
        i = ::IsoDoc::XrefGen::Counter.new(0, prefix: "#{num}.")
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          annex_names1(c, i.increment(c).print, level + 1)
        end
      end

      def clause_order_main(docxml)
        [
          { path: "//sections/introduction" },
          { path: "//clause[@type = 'scope']" },
          { path: @klass.norm_ref_xpath },
          { path: "//sections/terms | " \
                  "//sections/clause[descendant::terms]" },
          { path: "//sections/definitions | " \
                  "//sections/clause[descendant::definitions][not(descendant::terms)]" },
          { path: @klass.middle_clause(docxml), multi: true },
        ]
      end

      def clause_order_annex(_docxml)
        [{ path: "//annex[not(@commentary = 'true')]", multi: true }]
      end

      def clause_order_back(_docxml)
        [
          { path: @klass.bibliography_xpath },
          { path: "//annex[@commentary = 'true']", multi: true },
          { path: "//indexsect", multi: true },
          { path: "//colophon/*", multi: true },
        ]
      end

      def section_names(clause, num, lvl)
        clause&.name == "introduction" and clause["unnumbered"] = "true"
        super
      end

      def back_clauses_anchor_names(xml)
        clause_order_back(xml).each do |a|
          xml.xpath(ns(a[:path])).each do |c|
            if c["commentary"] == "true" then commentary_names(c)
            else preface_names(c)
            end
            x = Nokogiri::XML::NodeSet.new(c.document, [c])
            sequential_asset_names(x, container: true)
            a[:multi] or break
          end
        end
      end

      def commentary_names(clause)
        preface_name_anchors(clause, 1, clause_title(clause))
        clause.xpath(ns(SUBCLAUSES)).each_with_object(Counter.new) do |c, i|
          commentary_names1(c, clause["id"], i.increment(c).print, 2)
        end
      end

      def commentary_names1(clause, root, num, level)
        commentary_name_anchors(clause, num, root, level)
        clause.xpath(ns(SUBCLAUSES))
          .each_with_object(Counter.new(0, prefix: "#{num}.")) do |c, i|
          commentary_names1(c, root, i.increment(c).print,
                            level + 1)
        end
      end

      def commentary_name_anchors(clause, num, root, level)
        @anchors[clause["id"]] =
          { label: num, xref: l10n("#{@labels['clause']} #{num}"),
            container: root,
            title: clause_title(clause), level: level, type: "clause",
            elem: @labels["clause"] }
      end

      def list_item_anchor_names(list, list_anchor, depth, prev_label,
refer_list)
        c = Counter.new(list["start"] ? list["start"].to_i - 1 : 0)
        list.xpath(ns("./li")).each do |li|
          bare_label, label =
            list_item_value(li, c, depth, { list_anchor: list_anchor,
                                            prev_label: prev_label, refer_list: depth == 1 ? refer_list : nil })
          li["id"] and @anchors[li["id"]] =
                         { label: bare_label, bare_xref: "#{bare_label})",
                           xref: "#{label})", type: "listitem",
                           refer_list: refer_list, container: list_anchor[:container] }
          (li.xpath(ns(".//ol")) - li.xpath(ns(".//ol//ol"))).each do |ol|
            list_item_anchor_names(ol, list_anchor, depth + 1, label,
                                   refer_list)
          end
        end
      end

      def list_item_value(entry, counter, depth, opts)
        label1 = counter.increment(entry).listlabel(entry.parent, depth)
        if depth > 2
          base = opts[:prev_label].match(/^(.*?)([0-9.]+)$/) # a) 1.1.1
          label1 = "#{base[2]}.#{label1}"
          [label1, list_item_anchor_label(label1, opts[:list_anchor],
                                          base[1].sub(/[^a-z0-9]*$/, ""), opts[:refer_list])]
        else
          [label1, list_item_anchor_label(label1, opts[:list_anchor], opts[:prev_label],
                                          opts[:refer_list])]
        end
      end
    end
  end
end
