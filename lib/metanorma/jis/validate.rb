module Metanorma
  module Jis
    class Validate < Iso::Validate
      def doctype_validate(_xmldoc)
        %w(japanese-industrial-standard technical-report
           technical-specification amendment).include? @doctype or
          @log.add("JIS_1", nil, params: [@doctype])
      end

      def script_validate(xmldoc)
        script = xmldoc&.at("//bibdata/script")&.text
        %w(Jpan Latn).include?(script) or
          @log.add("JIS_2", nil, params: [script])
      end

      def schema_file
        "jis.rng"
      end

      # Iso::Validate#validate migrated content checks but dropped the
      # RelaxNG pass; JIS still relies on it for attribute enumerations
      # such as p/@align.
      def validate(doc)
        super
        schema_validate(formattedstr_strip(doc.dup), schema_location)
      end

      def image_name_validate(xmldoc); end
      def norm_bibitem_style(xmldoc); end
      def xrefs_mandate_validate(root); end
    end
  end
end
