class Html2Doc
  class JIS < ::Html2Doc
    def list2para(list)
      return if list.xpath("./li").empty?

      list.xpath("./li").each do |l|
        list2para_level(l, list)
      end
    end

    def style_list(elem, level, liststyle, listnumber)
      liststyle or return
      elem["level"] = level
      super
    end

    def list2para_level(item, list)
      level = item["level"]
      item.delete("level")
      item.name = "p"
      list2para_nest(item, level, list) if level
    end

    def list2para_nest(item, level, list)
      item["class"] = list2para_style(list.name, level)
      item.xpath("./p").each do |p|
        p["class"] = list2para_class(list.name, level)
        p["style"] = item["style"]
        (a = list2para_style(list.name, level)) && !a.empty? and
          p["style"] = "#{a};#{p['style']}"
        p["id"] = item["id"]
      end
      item.at("./p") or return
      item.replace(item.children)
    end

    def list2para_unnest_para(para, first_p, last_p)
      return if last_p.xpath("./following-sibling::* | ./following-sibling::text()")
        .any? do |x|
                  !x.text.strip.empty?
                end

      prev = first_p.xpath("./preceding-sibling::* | " \
                           "./preceding-sibling::text()[normalize-space()]")
      # bullet, tab, paragraph: ignore bullet, tab
      if prev.empty? then para.replace(para.children)
      elsif prev.size == 2 && prev[-1].name == "span" &&
          prev[-1]["style"] == "mso-tab-count:1"
        first_p.replace(first_p.children)
      end
    end

    def list2para_class(listtype, depth)
      case listtype
      when "ol" then "MsoList"
      when "ul"
        case depth
        when "1" then "MsoListBullet"
        when "2", "3", "4", "5" then "MsoListBullet#{depth}"
        else "MsoListBullet6"
        end
      end
    end

    def list2para_style(listtype, depth)
      case listtype
      when "ol"
        ret = case depth
              when "1" then "margin-left: 36.0pt;"
              when "2" then "margin-left: 54.0pt;"
              when "3" then "margin-left: 72.0pt;"
              when "4" then "margin-left: 90.0pt;"
              when "5" then "margin-left: 108.0pt;"
              when "6" then "margin-left: 126.0pt;"
              when "7" then "margin-left: 144.0pt;"
              when "8" then "margin-left: 162.0pt;"
              else "margin-left: 180.0pt;"
              end
        "#{ret}text-indent:-18.0pt;"
      when "ul"
        ret = case depth
              when "1" then "margin-left: 36.0pt;"
              when "2" then "margin-left: 45.95pt;"
              when "3" then "margin-left: 72.0pt;"
              when "4" then "margin-left: 90.0pt;"
              when "5" then "margin-left: 108.0pt;"
              when "6" then "margin-left: 126.0pt;"
              when "7" then "margin-left: 144.0pt;"
              when "8" then "margin-left: 162.0pt;"
              else "margin-left: 180.0pt;"
              end
        "#{ret}text-indent:-18.0pt;"

      end
    end

    def lists(docxml, liststyles)
      super
      docxml.xpath("//p[ol | ul]").each do |p|
        list2para_unnest_para(p, p.at("./ol | ./ul"),
                              p.at("./*[name() = 'ul' or name() = 'ol'][last()]"))
      end
      docxml.xpath("//ol | //ul").each do |u|
        u.replace(u.children)
      end
      unnest_list_paras(docxml)
    end

    def unnest_list_paras(docxml)
      docxml.xpath("//p[@class = 'MsoList' or @class = 'MsoListBullet']" \
                   "[.//p]").each do |p|
                     p.at("./p") and
                       list2para_unnest_para(p, p.at("./p"),
                                             p.at("./p[last()]"))
                     p.xpath(".//p[p]").each do |p1|
                       list2para_unnest_para(p1, p1.at("./p"),
                                             p1.at("./p[last()]"))
                     end
                   end
    end

    def list_add(xpath, liststyles, listtype, level)
      xpath.each do |l|
        level == 1 and l["seen"] = true and @listnumber += 1
        l["seen"] = true if level == 1
        l["id"] ||= UUIDTools::UUID.random_create
        list_add_number(l, liststyles, listtype, level)
        list_add_tail(l, liststyles, listtype, level)
      end
    end

    def list_add_number(list, liststyles, listtype, level)
      i = list["start"] and @listnumber = list["start"].to_i - 1
      (list.xpath(".//li") - list.xpath(".//ol//li | .//ul//li")).each do |li|
        style_list(li, level, liststyles[listtype], @listnumber)
        list_add1(li, liststyles, listtype, level)
      end
    end

    def list_add_tail(list, liststyles, listtype, level)
      list.xpath(".//ul[not(ancestor::li/ancestor::*/@id = '#{list['id']}')] | " \
                 ".//ol[not(ancestor::li/ancestor::*/@id = '#{list['id']}')]")
        .each do |li|
        list_add1(li.parent, liststyles, listtype, level - 1)
      end
    end

    def cleanup(docxml)
      super
      docxml.xpath("//div[@class = 'Quote' or @class = 'Example' or " \
                   "@class = 'Note']").each do |d|
        d.delete("class")
      end
      docxml
    end
  end
end
