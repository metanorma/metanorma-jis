require "metanorma-iso"

module Relaton
  module Render
    module Jis
      class Fields < ::Relaton::Render::Fields
        def edition_fields_format(hash)
          super
          hash[:version] = versionformat(hash[:edition_raw], hash)
        end

        def versionformat(edn, context)
          edn && !edn.empty? or return
          @r.i18n.select(context).populate("version_cardinal", { "var1" => edn })
        end
      end
    end
  end
end
