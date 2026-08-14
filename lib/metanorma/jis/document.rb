# frozen_string_literal: true

require "metanorma/standoc"
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
