module IsoDoc
  module JIS
    class WordConvert < IsoDoc::Iso::WordConvert
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
          notes_etc: figure_notes_examples_paras(node
          .xpath(ns("./note[not(@type = 'units')] | ./example | ./p"))),
          name: node.at(ns("./name")),
          key: node.at(ns("./dl")),
          img: node.at(ns("./image")),
          aside: node.at(ns("./aside")),
          subfigs: node.xpath(ns("./figure")).map { |n| figure_components(n) } }
      end

      def figure_notes_examples_paras(xpath)
        xpath.empty? and return nil
        curr = ""
        xpath.each_with_object([]) do |e, m|
          e.name == curr or m << []
          curr = e.name
          m[-1] << e
        end
      end

      def figure_parse1(node, out)
        c = figure_components(node)
        out.table **figure_attrs(node) do |div|
          %i(units img subfigs key notes_etc aside name).each do |key|
            case key
            when :subfigs
              c[key].each do |n|
                n[:subname] = n[:name]
                figure_row(node, div, n, :img)
                figure_row(node, div, n, :subname)
              end
            when :notes_etc
              c[key].each do |n|
                figure_row(node, div, n, :notes_etc)
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
        key != :notes_etc && (
        hash[key].nil? || (hash[key].is_a?(Array) && hash[key].empty?)) and
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
        when :notes_etc, :aside
          hash.each { |n| parse(n, cell) }
        when :name then figure_name_parse(node, cell, hash[key])
        when :img
          cell.p class: "Figure" do |p|
            parse(hash[key], p)
          end
        when :subname
          cell.p class: "SubfigureCaption" do |p|
            hash[key].children.each { |n| parse(n, p) }
          end
        end
      end
    end
  end
end
