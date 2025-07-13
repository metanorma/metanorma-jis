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

      # use Japanese ordinals for era years
      def japanese_date(date)
        date.nil? and return date
        d = date.split("-").map(&:to_i)
        time = Date.new(*d)
        yr = japanese_year(time)
        case d.size
        when 1 then yr
        when 2 then yr + time.strftime("%-m月")
        when 3 then yr + time.strftime("%-m月%-d日")
        else date
        end
      end

      def japanese_year(time)
        era_yr = time.era_year.to_i.localize(:ja)
          .to_rbnf_s("SpelloutRules", "spellout-numbering-year")
        "#{time.strftime('%JN')}#{era_yr}年"
      rescue StandardError
        time.year.to_s
      end
    end
  end
end
