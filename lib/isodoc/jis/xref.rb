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
      def annex_name_lbl(clause, num)
        obl = l10n("(#{@labels['inform_annex']})")
        clause["obligation"] == "normative" and
          obl = l10n("(#{@labels['norm_annex']})")
        title = Common::case_with_markup(@labels["annex"], "capital", @script)
        l10n("#{title} #{num}<br/>#{obl}")
      end

      def back_anchor_names(xml)
        if @parse_settings.empty? || @parse_settings[:clauses]
          i = Counter.new("@")
          xml.xpath(ns("//annex")).each do |c|
            if c["commentary"] == "true"
              commentary_names(c)
            else
              annex_names(c, i.increment(c).print)
            end
          end
          xml.xpath(ns(@klass.bibliography_xpath)).each do |b|
            preface_names(b)
          end
          xml.xpath(ns("//colophon/clause")).each { |b| preface_names(b) }
          xml.xpath(ns("//indexsect")).each { |b| preface_names(b) }
        end
        references(xml) if @parse_settings.empty? || @parse_settings[:refs]
      end

      def commentary_names(clause)
        preface_name_anchors(clause, 1, clause_title(clause))
        clause.xpath(ns(SUBCLAUSES)).each_with_object(Counter.new) do |c, i|
          commentary_names1(c, clause["id"], i.increment(c).print, 2)
        end
      end

      def commentary_names1(clause, root, num, level)
        commentary_name_anchors(clause, num, root, level)
        clause.xpath(ns(SUBCLAUSES)).each_with_object(Counter.new) do |c, i|
          commentary_names1(c, root, "#{num}.#{i.increment(c).print}",
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
          label = list_item_anchor_names_value(li, c, depth, { list_anchor: list_anchor, prev_label: prev_label,
                                                               refer_list: refer_list })
          li["id"] and @anchors[li["id"]] =
                         { xref: "#{label})", type: "listitem", refer_list:
                           refer_list, container: list_anchor[:container] }
          (li.xpath(ns(".//ol")) - li.xpath(ns(".//ol//ol"))).each do |ol|
            list_item_anchor_names(ol, list_anchor, depth + 1, label, false)
          end
        end
      end

      def list_item_anchor_names_value(entry, counter, depth, opts)
        label1 = counter.increment(entry).listlabel(entry.parent, depth)
        if depth > 2
          base = opts[:prev_label].match(/^(.*?)([0-9.]+)$/) # a) 1.1.1
          label1 = "#{base[2]}.#{label1}"
          list_item_anchor_label(label1, opts[:list_anchor],
                                 base[1].sub(/[^a-z0-9]*$/, ""), opts[:refer_list])
        else
          list_item_anchor_label(label1, opts[:list_anchor], opts[:prev_label],
                                 opts[:refer_list])
        end
      end
    end
  end
end
