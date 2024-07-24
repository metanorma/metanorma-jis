require "isodoc"
require "metanorma-iso"

module IsoDoc
  module JIS
    class Metadata < IsoDoc::Iso::Metadata
      def title(isoxml, _out)
        lang = @lang
        %w(en ja).include?(lang) or lang = "ja"
        tp = title_parts(isoxml, lang)
        tn = title_nums(isoxml)
        tp[:main] and set(:doctitlemain, tp[:main].children.to_xml)
        main = compose_title(tp, tn, lang)
        set(:doctitle, main)
        tp[:intro] and set(:doctitleintro, tp[:intro].children.to_xml)
        set(:doctitlepartlabel, part_prefix(tn, lang))
        tp[:part] and set(:doctitlepart, tp[:part].children.to_xml)
        set(:doctitleamdlabel, amd_prefix(tn, lang)) if tn[:amd]
        tp[:amd] and set(:doctitleamd, tp[:amd].children.to_xml)
        set(:doctitlecorrlabel, corr_prefix(tn, lang)) if tn[:corr]
      end

      def subtitle(isoxml, _out)
        lang = @lang == "ja" ? "en" : "ja"
        tp = title_parts(isoxml, lang)
        tn = title_nums(isoxml)
        tp[:main] and set(:docsubtitlemain, tp[:main].children.to_xml)
        main = compose_title(tp, tn, lang)
        set(:docsubtitle, main)
        tp[:intro] and set(:docsubtitleintro, tp[:intro].children.to_xml)
        set(:docsubtitlepartlabel, part_prefix(tn, lang))
        tp[:part] and set(:docsubtitlepart, tp[:part].children.to_xml)
        set(:docsubtitleamdlabel, amd_prefix(tn, lang)) if tn[:amd]
        tp[:amd] and set(:docsubtitleamd, tp[:amd].children.to_xml)
        set(:docsubtitlecorrlabel, corr_prefix(tn, lang)) if tn[:corr]
      end

      def set_encoded(name, field)
        field or return
        field.respond_to?(:text) and field = field.text
        set(name, @c.encode(field, :hexadecimal))
      end

      PART_LABEL = { en: "Part", ja: "その" }.freeze

      def docid(isoxml, _out)
        id = isoxml.at(ns("//bibdata/docidentifier[@type = 'JIS']"))&.text or
          return
        set(:docnumber, id)
        set(:docnumber_undated, id.sub(/:\d{4}$/, ""))
      end

      def bibdate(isoxml, _out)
        isoxml.xpath(ns("//bibdata/date")).each do |d|
          val = Common::date_range(d)
          @lang == "ja" and val = @i18n.japanese_date(val)
          set("#{d['type'].gsub(/-/, '_')}date".to_sym, val)
        end
      end

      def version(isoxml, out)
        super
        @lang == "ja" or return
        revdate = @i18n.japanese_date(isoxml
          .at(ns("//bibdata/version/revision-date"))&.text)
        set(:revdate, revdate)
        set(:draftinfo, draftinfo(get[:draft], revdate))
      end

      def agency(xml)
        super
        investigative_organisation(xml)
        investigative_committee(xml)
      end

      def extract_role(role, desc)
        <<~XPATH
          //bibdata/contributor[xmlns:role/@type = '#{role}'][xmlns:role/description = '#{desc}' or xmlns:role/description = '#{desc.downcase}']
        XPATH
      end

      def investigative_organisation(xml)
        p = extract_role("authorizer", "Investigative organization")
        org = xml.at(ns("#{p}/organization/name[@language = '#{@lang}']"))
        org ||= xml.at(ns("#{p}/organization/name"))
        if org then set_encoded(:"investigative-organization", org)
        else set(:"investigative-organization", get[:publisher])
        end
      end

      def investigative_committee(xml)
        xpath = extract_role("authorizer", "Investigative committee")
        if o = xml.at(ns("#{xpath}/organization/name"))
          set_encoded(:"investigative-committee", o)
        elsif p = xml.at(ns("#{xpath}/person"))
          investigative_committee_person(p)
        end
      end

      def investigative_committee_person(person)
        n = extract_person_names([person])
        pos = person.at(ns("./affiliation/name")) || @i18n.chairperson
        org = person.at(ns("./affiliation/organization/name"))
        set_encoded(:"investigative-committee", org)
        unless n.empty?
          set_encoded(:"investigative-committee-representative-role", pos)
          set(:"investigative-committee-representative-name", n.first)
        end
      end
    end
  end
end
