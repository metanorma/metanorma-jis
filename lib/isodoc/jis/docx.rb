# frozen_string_literal: true

require "isodoc"
require "metanorma-iso"
require "uniword"

module IsoDoc
  module Jis
    module Docx
      autoload :Adapter, "isodoc/jis/docx/adapter"
      autoload :StyleMapping, "isodoc/jis/docx/style_mapping"
      autoload :StyleResolver, "isodoc/jis/docx/style_resolver"
      autoload :CoverRenderer, "isodoc/jis/docx/cover_renderer"
      autoload :BodyRenderer, "isodoc/jis/docx/body_renderer"
      autoload :InlineRenderer, "isodoc/jis/docx/inline_renderer"
      autoload :Errors, "isodoc/jis/docx/errors"
    end
  end
end
