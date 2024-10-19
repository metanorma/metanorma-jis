require "metanorma-iso"

module Relaton
  module Render
    module Jis
      class Parse < ::Relaton::Render::Iso::Parse
        def simple_or_host_xml2hash(doc, host)
          ret = super
          orgs = %i(publisher_raw author_raw authorizer_raw)
            .each_with_object([]) do |i, m|
            ret[i] and m << ret[i]
          end
          ret.merge(home_standard: home_standard(doc, orgs.flatten))
        end

        def home_standard(_doc, pubs)
          pubs&.any? do |r|
            ["International Organization for Standardization", "ISO",
             "International Electrotechnical Commission", "IEC",
             "日本規格協会", "一般財団法人　日本規格協会",
             "Japanese Industrial Standards"]
              .include?(r[:nonpersonal])
          end
        end
      end
    end
  end
end
