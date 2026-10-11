require "asciidoctor" unless defined? Asciidoctor::Converter
require "metanorma-core"
require "metanorma-iso"
require "metanorma/jis"
require "isodoc/jis"

if defined? Metanorma::Registry
  Metanorma::Registry.instance.register(Metanorma::Jis::Processor)
end
