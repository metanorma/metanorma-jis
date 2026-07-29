# frozen_string_literal: true

# JIS document model — vendored under `Metanorma::Jis::Document`.
#
# This is the typed interface between presentation XML and the DOCX Adapter:
# XML is parsed once into a typed model that serves many renderers.
#
# Architecture (mirrors `Metanorma::IsoDocument`):
#   lib/metanorma/jis/document.rb        <- this file (autoloads)
#   lib/metanorma/jis/document/root.rb   <- Metanorma::Jis::Document::Root
#   lib/metanorma/jis/document/cover.rb  <- typed cover metadata
#   lib/metanorma/jis/document/sections/*.rb
#   lib/metanorma/jis/document/terms/*.rb
#
# Serialization is exclusively via lutaml-model — no hand-rolled to_h / from_h.
# Section-type dispatch drives the Adapter's Renderers::Registry (OCP):
# each new section type = one model class + one renderer class + one
# registration line in the registry.

require "metanorma/document"

module Metanorma
  module Jis
    module Document
      autoload :Root, "#{__dir__}/document/root"
      autoload :Cover, "#{__dir__}/document/cover"
      autoload :Namespace, "#{__dir__}/document/namespace"
      autoload :Sections, "#{__dir__}/document/sections"
      autoload :Terms, "#{__dir__}/document/terms"
    end
  end
end
