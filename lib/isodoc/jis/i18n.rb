module IsoDoc
  module JIS
    class I18n < IsoDoc::Iso::I18n
      def load_yaml1(lang, script)
        require "debug"; binding.b
        y = if lang == "ja"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-ja.yaml"))
            else
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-ja.yaml"))
            end
        super.deep_merge(y)
      end
    end
  end
end

