require_relative "base_convert"
require "isodoc"

module IsoDoc
  module Jis
    class PdfConvert < IsoDoc::XslfoPdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def pdf_stylesheet(_docxml)
        "jis.international-standard.xsl"
      end
    end
  end
end
