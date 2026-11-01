require "asciidoctor" unless defined? Asciidoctor::Converter
require "metanorma-core"
require "metanorma-iso"
require "metanorma/jis"
# Force-load: `register_for "jis"` (inside) must run before any
# Asciidoctor.load with backend :jis. The autoload in metanorma/jis.rb
# never fires on its own — nothing references the constant first — so
# bare FlavorLoader paths (e.g. `metanorma site generate`) crashed with
# "missing converter for backend 'jis'".
require "metanorma/jis/converter"
require "isodoc/jis"

if defined? Metanorma::Registry
  Metanorma::Registry.instance.register(Metanorma::Jis::Processor)
end
