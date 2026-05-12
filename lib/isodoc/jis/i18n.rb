require "japanese_calendar"
require "twitter_cldr"

module IsoDoc
  module Jis
    class I18n < IsoDoc::Iso::I18n
      def jis_load_file(fname)
        f = File.join(File.dirname(__FILE__), fname)
        File.exist?(f) ? YAML.load_file(f) : {}
      end

      def load_yaml1(lang, script)
        y = jis_load_file("i18n-#{yaml_lang(lang, script)}.yaml")
        if y.empty?
          jis_load_file("i18n-en.yaml").merge(super)
        else
          super.deep_merge(y)
        end
      end

      def japanese_date(date, japanese_numbering: false)
        branch = japanese_numbering ? "japanese_numbering" : "default"
        fmts = @labels.dig("date_format", branch) || {}
        IsoDoc::ExtendedDateFormatter.format_iso_date(
          date,
          lang: "ja",
          year: fmts["year"],
          year_month: fmts["year_month"],
          full: fmts["full"],
        )
      end
    end
  end
end
