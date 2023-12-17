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
        set_encoded(:doctitlemain, tp[:main])
        main = compose_title(tp, tn, lang)
        set(:doctitle, main)
        set_encoded(:doctitleintro, tp[:intro])
        set(:doctitlepartlabel, part_prefix(tn, lang))
        set_encoded(:doctitlepart, tp[:part])
        set(:doctitleamdlabel, amd_prefix(tn, lang)) if tn[:amd]
        set_encoded(:doctitleamd, tp[:amd])
        set(:doctitlecorrlabel, corr_prefix(tn, lang)) if tn[:corr]
      end

      def subtitle(isoxml, _out)
        lang = @lang == "ja" ? "en" : "ja"
        tp = title_parts(isoxml, lang)
        tn = title_nums(isoxml)
        set_encoded(:docsubtitlemain, tp[:main])
        main = compose_title(tp, tn, lang)
        set(:docsubtitle, main)
        set_encoded(:docsubtitleintro, tp[:intro])
        set(:docsubtitlepartlabel, part_prefix(tn, lang))
        set_encoded(:docsubtitlepart, tp[:part])
        set(:docsubtitleamdlabel, amd_prefix(tn, lang)) if tn[:amd]
        set_encoded(:docsubtitleamd, tp[:amd])
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

      def investigative_organisation(xml)
        xpath = "//bibdata/contributor" \
          "[xmlns:role/@type = 'authorizer'][xmlns:role/description = " \
          "'investigative organization']/organization/name"
        org = xml.at(ns(xpath))
        if org then set_encoded(:"investigative-organization", org)
        else set(:"investigative-organization", get[:publisher])
        end
      end

      def investigative_committee(xml)
        xpath = "//bibdata/contributor" \
          "[xmlns:role/@type = 'authorizer'][xmlns:role/description = " \
          "'investigative committee']"
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
