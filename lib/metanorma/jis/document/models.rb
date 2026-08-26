# frozen_string_literal: true

require "metanorma/standoc"
require "metanorma/iso/document/models"
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

module Metanorma
  existing = defined?(Metanorma::JisDocument) && Metanorma::JisDocument
  if !existing.equal?(Metanorma::Jis::Document)
    Metanorma.send(:remove_const, :JisDocument) if existing
    JisDocument = Metanorma::Jis::Document
  end
end
