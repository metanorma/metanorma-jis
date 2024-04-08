require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "metanorma/jis/converter"
require_relative "metanorma/plateau/converter"
require_relative "metanorma/jis/version"
require "isodoc/jis/html_convert"
require "isodoc/jis/word_convert"
require "isodoc/jis/pdf_convert"
require "isodoc/jis/presentation_xml_convert"
require "isodoc/jis/metadata"
require "isodoc/jis/xref"
require "isodoc/plateau/html_convert"
require "isodoc/plateau/word_convert"
require "isodoc/plateau/pdf_convert"
require "isodoc/plateau/presentation_xml_convert"
require "isodoc/plateau/metadata"
require "isodoc/plateau/xref"
require "metanorma"

if defined? Metanorma::Registry
  require_relative "metanorma/jis"
  Metanorma::Registry.instance.register(Metanorma::JIS::Processor)
  require_relative "metanorma/plateau"
  Metanorma::Registry.instance.register(Metanorma::Plateau::Processor)
end

