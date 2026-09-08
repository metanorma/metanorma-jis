# frozen_string_literal: true

require "metanorma/standoc"
require "metanorma/iso/document"
# Forward-declare parent namespace so this file is safe to require
# directly (without first requiring metanorma/jis.rb).
module Metanorma
  module Jis
  end
end


module Metanorma
  module Jis::Document
    autoload :Metadata, "metanorma/jis/document/metadata"
    autoload :Root, "metanorma/jis/document/root"
    autoload :Sections, "metanorma/jis/document/sections"
  end
end


# Backwards-compat alias so external consumers that reference
# Metanorma::JisDocument keep resolving during the transition.
module Metanorma
  existing = defined?(Metanorma::JisDocument) && Metanorma::JisDocument
  if !existing.equal?(Metanorma::Jis::Document)
    Metanorma.send(:remove_const, :JisDocument) if existing
    JisDocument = Metanorma::Jis::Document
  end
end

if defined?(Metanorma::Registers::Setup.setup_jis_register)
  Metanorma::Registers::Setup.setup_jis_register
end

module Metanorma
  deprecate_constant :JisDocument
end

require "metanorma-core"

# OCP adoption: ONE registration in the metanorma-core flavor table
# (metanorma-core#18). Lazy: the table exists only on the flavor-table
# line of metanorma-core; skip silently on resolutions without it.
if defined?(Metanorma::Core::Flavors)
  Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
                                      name: :jis,
                                      gem: "metanorma-jis",
                                      model_root: Metanorma::Jis::Document::Root,
                                      pubid_module: nil,
                                      renderers: { html: lambda do |_document, **_options|
                                        require "metanorma/jis/html"
                                        Metanorma::Jis::Html::Renderer
                                      end },
                                    ))
end
