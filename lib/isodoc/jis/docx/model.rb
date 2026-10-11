# frozen_string_literal: true

# JIS presentation-XML document model — `IsoDoc::Jis::Docx::Model`.
#
# This is the typed interface between presentation XML (<jis-standard>)
# and the DOCX Adapter: XML is parsed once into a typed model that serves
# many renderers.
#
# Architecture (mirrors `Metanorma::IsoDocument`):
#   lib/isodoc/jis/docx/model.rb        <- this file (autoloads)
#   lib/isodoc/jis/docx/model/root.rb   <- IsoDoc::Jis::Docx::Model::Root
#   lib/isodoc/jis/docx/model/cover.rb  <- typed cover metadata
#   lib/isodoc/jis/docx/model/sections/*.rb
#   lib/isodoc/jis/docx/model/terms/*.rb
#
# Serialization is exclusively via lutaml-model — no hand-rolled to_h / from_h.
# Section-type dispatch drives the Adapter's Renderers::Registry (OCP):
# each new section type = one model class + one renderer class + one
# registration line in the registry.
#
# Distinct from Metanorma::Jis::Document (the semantic <metanorma> model
# registered in the :jis_document lutaml register): this model parses the
# isodoc presentation XML that the DOCX Adapter consumes.

require "metanorma/document"

module IsoDoc
  module Jis
    module Docx
      module Model
        autoload :Root, "#{__dir__}/model/root"
        autoload :Cover, "#{__dir__}/model/cover"
        autoload :Namespace, "#{__dir__}/model/namespace"
        autoload :Sections, "#{__dir__}/model/sections"
        autoload :Terms, "#{__dir__}/model/terms"
      end
    end
  end
end
