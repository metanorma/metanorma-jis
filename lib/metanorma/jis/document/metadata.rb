# frozen_string_literal: true

module Metanorma
  module Jis::Document
    module Metadata
      autoload :JisBibDataExtensionType,
               "#{__dir__}/metadata/jis_bib_data_extension_type"
      autoload :JisBibliographicItem,
               "#{__dir__}/metadata/jis_bibliographic_item"
    end
  end
end