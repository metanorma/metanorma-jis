module IsoDoc
  module JIS
    class I18n < IsoDoc::Iso::I18n
      def load_yaml1(lang, script)
        y = if lang == "jp"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-jp.yaml"))
            else
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-jp.yaml"))
            end
        super.deep_merge(y)
      end
    end
  end
end

