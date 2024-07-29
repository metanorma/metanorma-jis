require "metanorma-iso"

module Relaton
  module Render
    module JIS
      class Parse < ::Relaton::Render::Iso::Parse
        def simple_or_host_xml2hash(doc, host)
          ret = super
          ret.merge(home_standard: home_standard(doc, ret[:publisher_raw] ||
                                                 ret[:author_raw]))
        end

        def home_standard(_doc, pubs)
          pubs&.any? do |r|
            ["International Organization for Standardization", "ISO",
             "International Electrotechnical Commission", "IEC",
             "一般財団法人　日本規格協会", "Japanese Industrial Standards"]
              .include?(r[:nonpersonal])
          end
        end
      end
    end
  end
end
