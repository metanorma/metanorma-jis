# frozen_string_literal: true

require_relative "document/models"
require "metanorma/jis/registers"
Metanorma::Jis::Registers.setup

# OCP adoption: ONE registration in the metanorma-core flavor table
require "metanorma-core"

Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
  name: :jis,
  gem: "metanorma-jis",
  model_root: Metanorma::Jis::Document::Root,
  pubid_module: nil,
  renderers: { html: lambda do |_document, **_options|
    Metanorma::Html::StandardRenderer
  end },
))
