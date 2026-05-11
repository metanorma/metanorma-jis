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
        return date if date.nil?

        d = date.split("-").map(&:to_i)
        fmt = japanese_date_format(d.size, japanese_numbering) or return date
        IsoDoc::ExtendedDateFormatter.format(Date.new(*d), fmt, lang: "ja")
      rescue StandardError
        date
      end

      def japanese_date_format(arity, japanese_numbering)
        return nil unless (1..3).cover?(arity)

        branch = japanese_numbering ? "japanese_numbering" : "default"
        @labels.dig("date_format", branch, %w[year year_month full][arity - 1])
      end
    end
  end
end
