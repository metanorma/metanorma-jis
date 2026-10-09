# frozen_string_literal: true

require "relaton-render"

module Metanorma
  module Jis
    #
    # The JIS flavor's citation renderer: an extension of the
    # relaton-render General facade carrying this gem's CitationStyle
    # instances, one per document language. Supersedes the 1.x stack
    # this gem carried under lib/relaton/render-jis, which subclassed
    # metanorma-iso's deleted 1.x renderer.
    #
    class CitationStyle < ::Relaton::Render::General
      STYLES = {
        "ja" => File.join(__dir__, "jis-style-ja.yml"),
        "en" => File.join(__dir__, "jis-style-en.yml"),
      }.freeze

      def style_path(lang)
        STYLES[lang.to_s] || STYLES.values.first
      end

      # The JIS reference does not take the biblio terminator, titles
      # collapse to single-spacing, and CJK typography applies to
      # Japanese renderings
      def render_all(bib, type: "author-date")
        ret = super or return nil
        ret.each_value { |k| render_all_tidy(k) }
        ret
      end

      # CJK typography takes the four-per-em space after CJK
      # punctuation (。、：) in place of the ASCII space
      def render(model, **opts)
        out = super
        @lang.to_s.start_with?("ja") ? cjk_spacing(out) : out
      end

      private

      def render_all_tidy(renderings)
        renderings.each do |key, v|
          case v
          when String then renderings[key] = tidy(v)
          when Hash then v.each { |ck, cv| v[ck] = tidy(cv) if cv.is_a?(String) }
          end
        end
      end

      # The short cite's author part ends without its period: the
      # period is the separator that follows the split marker
      FIRST_DELIM = '<span class="fmt-first-biblio-delim"/>'.freeze

      # The 1.x renderings carried no trailing biblio period, and the
      # model's markup-preserved titles brought newlines the 1.x
      # templates had collapsed
      def tidy(text)
        out = text.to_s.gsub(/\s+/, " ")
          .sub(/[.。]\s*\z/, "")
          .gsub(".#{FIRST_DELIM}", FIRST_DELIM)
        @lang.to_s.start_with?("ja") ? cjk_spacing(out) : out
      end

      FOUR_PER_EM = "\u2005".freeze

      def cjk_spacing(text)
        text.to_s
          .gsub(/。+/) { "。" }
          # a space after the CJK period takes the four-per-em space
          # (letters and digits); the other separators take it before
          # letters alone
          .gsub(/。 (?=[A-Za-z0-9])/) { "。#{FOUR_PER_EM}" }
          .gsub(/([、：；]) (?=[A-Za-z<])/) { "#{Regexp.last_match(1)}#{FOUR_PER_EM}" }
          # a CJK period directly before Latin text takes it too
          .gsub(/。(?=[A-Za-z])/) { "。#{FOUR_PER_EM}" }
          # a space before CJK text closes up entirely
          .gsub(/([。、：；]) (?=第|一-鿿|\p{Han}|\p{Hiragana}|\p{Katakana})/) { Regexp.last_match(1) }
          # a sentence period after a closing CJK separator yields to it
          .gsub(/([：、；])。/) { Regexp.last_match(1) }
          # the role marker's fullwidth paren stands after a period
          # ("P. （編）") and closes up after a word ("Bradner（編）")
          .gsub(/\.（編）/u) { ". （編）" }
      end

      # A collection's items may each declare their own language: the
      # per-language renderer carries that language's JIS style
      def renderer_for(lang)
        return @renderer if lang.nil? || lang == @lang

        @renderers_by_lang[lang] ||= JisElements::JisRenderer.new(
          lang: lang,
          script: @renderer_opts[:script],
          labels: @renderer_opts[:labels],
          style: style_path(lang),
        )
      end

      def initialize(options = {})
        super
        options = deep_symbolize(options)
        @renderer = JisElements::JisRenderer.new(
          lang: @lang,
          script: options[:script] || "Latn",
          labels: options[:i18nhash] || {},
          style: options[:style] || style_path(@lang),
        )
      end
    end
  end
end
