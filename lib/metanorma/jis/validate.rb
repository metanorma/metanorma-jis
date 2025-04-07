module Metanorma
  module Jis
    class Converter < Iso::Converter
      def doctype_validate(_xmldoc)
        %w(japanese-industrial-standard technical-report
           technical-specification amendment).include? @doctype or
          @log.add("Document Attributes", nil,
                   "#{@doctype} is not a recognised document type")
      end

      def script_validate(xmldoc)
        script = xmldoc&.at("//bibdata/script")&.text
        %w(Jpan Latn).include?(script) or
          @log.add("Document Attributes", nil,
                   "#{script} is not a recognised script")
      end

      def schema_file
        "jis.rng"
      end

      def image_name_validate(xmldoc); end
      def norm_bibitem_style(xmldoc); end
      def xrefs_mandate_validate(root); end
    end
  end
end
