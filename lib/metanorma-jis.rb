require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "metanorma/jis/converter"
require_relative "metanorma/jis/version"
require "isodoc/jis/html_convert"
require "isodoc/jis/pdf_convert"
require "isodoc/jis/presentation_xml_convert"
require "isodoc/jis/metadata"
require "metanorma"

if defined? Metanorma::Registry
  require_relative "metanorma/jis"
  Metanorma::Registry.instance.register(Metanorma::JIS::Processor)
end

