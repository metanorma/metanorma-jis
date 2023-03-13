require_relative "init"
require "isodoc"

module IsoDoc
  module JIS
    class PresentationXMLConvert < IsoDoc::Iso::PresentationXMLConvert

      include Init
    end
  end
end
