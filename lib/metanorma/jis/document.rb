# frozen_string_literal: true

require "metanorma/standoc"
module Metanorma
  module Jis
  end
end

module Metanorma
  module Jis::Document
  end
end

module Metanorma
  existing = defined?(Metanorma::JisDocument) && Metanorma::JisDocument
  if !existing.equal?(Metanorma::Jis::Document)
    Metanorma.send(:remove_const, :JisDocument) if existing
    JisDocument = Metanorma::Jis::Document
  end
end

# OCP adoption: ONE registration in the metanorma-core flavor table
require "metanorma-core"

Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
  name: :jis,
  gem: "metanorma-jis",
  model_root: Metanorma::Jis::Document::Root,
  pubid_module: nil,
  renderers: { html: Metanorma::Html::StandardRenderer },
))
