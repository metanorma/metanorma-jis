module Metanorma
  module Jis
    class Converter < ISO::Converter
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

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "jis.rng"))
      end

      def image_name_validate(xmldoc); end
      def norm_bibitem_style(xmldoc); end
      def xrefs_mandate_validate(root); end
    end
  end
end
