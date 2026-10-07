# frozen_string_literal: true

require "relaton-render"

module Metanorma
  module Jis
    # JIS-specific data elements extending the engine's ISO 690
    # vocabulary, passed to the renderer as its element map
    module JisElements
      HOME_PUBLISHERS = [
        "International Organization for Standardization", "ISO",
        "International Electrotechnical Commission", "IEC",
        "日本規格協会", "一般財団法人　日本規格協会",
        "Japanese Industrial Standards",
      ].freeze

      # The host of a part citation, 1.x parity: the host title, then
      # the host's principal creator, closed by a paren the 1.x cleanup
      # had orphaned when the host role came out empty ("Collected
      # Essays UNICEF)"). The stddocTitle engine element marks home
      # standards.
      class ComponentPart < ::Relaton::Render::Iso690::Elements::ComponentPart
        def render
          return "" if host_title_text.empty?

          "#{host_title_text} #{host_creators}#{close_paren}".strip
        end

        private

        def host_creators
          author = Array(host&.contributor)
            .find { |c| has_role?(c, "author") } or return ""

          person = author.person
          if person.nil?
            Array(author.organization&.name).map { |n| localized(n) }
              .reject(&:empty?).join(", ")
          else
            host_person_name(author, first: true)
          end
        end

        def close_paren
          @i18n.punct_fetch("close-paren", ")")
        end
      end

      # A part cites its host's series when it carries none of its own
      # (the 1.x series fallback to the host document)
      class Series < ::Relaton::Render::Iso690::Elements::Series
        private

        def series
          super || Array(host_relation&.bibitem&.series).first
        end

        def host_relation
          Array(@model.relation).find do |r|
            ComponentPart::HOST_RELATION_TYPES.include?(r.type)
          end
        end
      end

      # The book-family extent carries the volume and the page only,
      # and repeated localities of one type collapse to the last
      # declared (the 1.x per-type merge)
      class Extent < ::Relaton::Render::Iso690::Elements::Extent
        def render
          return super unless book_family?

          [volume_part, page_part].reject(&:empty?).join(" ")
        end

        private

        def book_family?
          %w[book inbook incollection inproceedings proceedings]
            .include?(@model.type.to_s)
        end

        def volume_part
          loc = pick("volume") or return ""
          loc.reference_from.to_s.empty? ? "" :
            unit("volume", loc.reference_from)
        end

        def page_part
          loc = pick("page") or return ""
          from = loc.reference_from.to_s
          to = loc.reference_to.to_s
          if to.empty? || to == from
            unit("page", from)
          else
            unit("pages", "#{from}#{@i18n.label('date_range')}#{to}")
          end
        end

        # The last locality of a type wins (the 1.x merge)
        def pick(type)
          localities.reverse.find { |l| l.type == type }
        end
      end

      class JisRenderer < ::Relaton::Render::Iso690::Renderer
        def home_docid?(model)
          JisElements.home_publisher?(model)
        end
      end

      ELEMENTS = {
        component_part: JisElements::ComponentPart,
        series: JisElements::Series,
        extent: JisElements::Extent,
      }.freeze

      module_function

      def home_publisher?(model)
        Array(model.contributor).any? do |c|
          next false unless Array(c.role).any? do |r|
            r.is_a?(String) ? r == "publisher" : r.type == "publisher"
          end

          Array(c.organization&.name).any? do |n|
            HOME_PUBLISHERS.include?(n.content)
          end
        end
      end
    end
  end
end
