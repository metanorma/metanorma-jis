require "isodoc"
require "metanorma-iso"

module IsoDoc
  module JIS
    module BaseConvert
      def middle_title(_isoxml, out)
        middle_title_main(out)
        middle_subtitle_main(out)
        # middle_title_amd(out)
      end

      def middle_title_main(out)
        out.p(class: "zzSTDTitle1") do |p|
          p << @meta.get[:doctitleintro]
          p << " &#x2014; " if @meta.get[:doctitleintro] && @meta.get[:doctitlemain]
          p << @meta.get[:doctitlemain]
          p << " &#x2014; " if @meta.get[:doctitlemain] && @meta.get[:doctitlepart]
        end
        a = @meta.get[:doctitlepart] and out.p(class: "zzSTDTitle1") do |p|
          b = @meta.get[:doctitlepartlabel] and p << "#{b}: "
          p << "<br/><b>#{a}</b>"
        end
      end

      def middle_subtitle_main(out)
        @meta.get[:docsubtitlemain] or return
        out.p(class: "zzSTDTitle2") do |p|
          p << @meta.get[:docsubtitleintro]
          p << " &#x2014; " if @meta.get[:docsubtitleintro] && @meta.get[:docsubtitlemain]
          p << @meta.get[:docsubtitlemain]
          p << " &#x2014; " if @meta.get[:docsubtitlemain] && @meta.get[:docsubtitlepart]
        end
        a = @meta.get[:docsubtitlepart] and out.p(class: "zzSTDTitle2") do |p|
          b = @meta.get[:docsubtitlepartlabel] and p << "#{b}: "
          p << "<br/><b>#{a}</b>"
        end
      end
    end
  end
end
