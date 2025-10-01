module IsoDoc
  module XrefGen
    module OlTypeProvider
      def ol_type(list, depth)
        return list["type"].to_sym if list["type"]
        return :alphabet if depth == 1
        @style == :japanese ? :japanese : :arabic
      end
    end
  end

  module Jis
    class Counter < IsoDoc::XrefGen::Counter
      def listlabel(_list, depth)
        case depth
        when 1 then (96 + @num).chr.to_s
        else
          if @style == :japanese
            @num.localize(:ja).spellout
          else
            @num.to_s
          end
        end
      end
    end

    class Xref < IsoDoc::Iso::Xref
      attr_accessor :autonumbering_style

      def clausesep
        @autonumbering_style == :japanese ? "\u30fb" : "."
      end

      def clause_counter(num, opts = { })
        opts[:numerals] ||= @autonumbering_style
        opts[:separator] ||= clausesep
        super
      end

      def list_counter(num, opts = { })
        opts[:numerals] ||= @autonumbering_style
        opts[:separator] ||= clausesep
        IsoDoc::Jis::Counter.new(num, opts)
      end

      def hierfigsep
        @lang == "ja" ? "の" : super
      end

      def hierreqtsep
        @lang == "ja" ? "の" : super
      end

      def subfigure_label(subfignum)
        subfignum.zero? and return
        (subfignum + 96).chr
      end

      def subfigure_delim
        ")"
      end

      # taken from isodoc to override ISO
      def subfigure_anchor(elem, sublabel, label, klass, container: false)
        figlabel = fig_subfig_label(label, sublabel)
        @anchors[elem["id"]] = anchor_struct(
          figlabel, elem, @labels[klass] || klass.capitalize, klass,
          { unnumb: elem["unnumbered"], container: }
        ) 
        if elem["unnumbered"] != "true"
          x = semx(elem, sublabel)
          p = elem.at("./ancestor::xmlns:figure")
          @anchors[elem["id"]][:label] = x
          @anchors[elem["id"]][:xref] = @anchors[p["id"]][:xref] + 
            subfigure_separator(markup: true) + x + delim_wrap(subfigure_delim)
        end
      end 

      def annex_name_lbl(clause, num)
        super.gsub(%r{</?strong>}, "")
      end

      def annex_name_anchors1(clause, num, level)
        super
        # undo ISO "Clause A.2" in favour of "A.2"
        level == 2 and
          @anchors[clause["id"]][:xref] =  semx(clause, num)
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

      def main_anchor_names(xml)
        n = Counter.new(0, { numerals: @autonumbering_style })
        clause_order_main(xml).each do |a|
          xml.xpath(ns(a[:path])).each do |c|
            section_names(c, n, 1)
            a[:multi] or break
          end
        end
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
        clause.xpath(ns(SUBCLAUSES))
          .each_with_object(clause_counter(0, {})) do |c, i|
            commentary_names1(c, clause["id"], nil, i.increment(c).print, 2)
          end
      end

      def commentary_names1(clause, root, parentnum, num, level)
        lbl = clause_number_semx(parentnum, clause, num)
        commentary_name_anchors(clause, lbl, root, level)
        clause.xpath(ns(SUBCLAUSES))
          .each_with_object(clause_counter(0)) do |c, i|
            commentary_names1(c, root, lbl, i.increment(c).print,
                              level + 1)
          end
      end

      def commentary_name_anchors(clause, num, root, level)
        @anchors[clause["id"]] =
          { label: num, xref: labelled_autonum(@labels["clause"], num),
            container: root,
            title: clause_title(clause), level: level, type: "clause",
            elem: @labels["clause"] }
      end

      def list_item_value(entry, counter, depth, opts)
        if depth > 2
          label = counter.increment(entry).listlabel(entry.parent, depth)
          s = semx(entry, label)
          base = @c.decode(opts[:prev_label].gsub(%r{<[^>]+>}, "")).split(/\)\s*/) # List a) 1.1.1
          label = "#{base[-1].sub(/^の/,'')}#{clausesep}#{label}"
          [label, opts[:prev_label] + delim_wrap(clausesep) + s]
        else
          super
        end
      end
    end
  end
end
