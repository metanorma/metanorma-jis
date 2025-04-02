module IsoDoc
  module Jis
    class PresentationXMLConvert < IsoDoc::Iso::PresentationXMLConvert
      def ol_depth(node)
        depth == 1 and return :alphabet
        :arabic
      end

         def ol_depth(node)
      depth = node.ancestors("ol").size + 1
      @counter.ol_type(node, depth) # defined in Xref::Counter
    end

         def ul_label_list(_elem)
      %w(&#xFF0D; &#x30FB;)
    end

    def ul_label_value(elem)
      depth = elem.ancestors("ul").size
      val = ul_label_list(elem)
      val[(depth - 1) % val.size]
    end

      # TODO: move the table/figure key processing to Word, not Presentation XML
      def dl(docxml)
        super
        docxml.xpath(ns("//table//dl | //figure//dl")).each do |l|
          l.at(ns("./dl")) || l.at("./ancestor::xmlns:dl") and next
          dl_to_para(l)
        end
      end

      def dt_dd?(node)
        %w{dt dd}.include? node.name
      end

      def dl_to_para(node)
        ret = dl_to_para_name(node)
        ret += dl_to_para_terms(node)
        node.elements.reject { |n| %w(dt dd name fmt-name).include?(n.name) }
          .each do |x|
          ret += x.to_xml
        end
        dl_id_insert(node, ret)
      end

      def dl_id_insert(node, ret)
        a = node.replace(ret)
        p = a.at("./descendant-or-self::xmlns:p")
        node["id"] and p << "<bookmark id='#{node['id']}'/>"
        a.xpath("./descendant-or-self::*[@id = '']").each { |x| x.delete("id") }
      end

      def dl_to_para_name(node)
        e = node.at(ns("./fmt-name")) or return ""
        node.parent.parent["type"] == "participants" and return ""
        "<p class='ListTitle'>#{e.children.to_xml}</p>"
      end

      def dl_to_para_terms(node)
        ret = ""
        node.elements.select { |n| dt_dd?(n) }.each_slice(2) do |dt, dd|
          term = strip_para(dt)
          defn = strip_para(dd)
          bkmk = dd["id"] ? "<bookmark id='#{dd['id']}'/>" : ""
          ret += "<p class='dl' id='#{dt['id']}'>#{term}: #{bkmk}#{defn}</p>"
        end
        ret
      end
    end
  end
end
