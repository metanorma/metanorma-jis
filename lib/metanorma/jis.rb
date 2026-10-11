require "metanorma-iso"

module Metanorma
  module Jis
    autoload :Converter, "metanorma/jis/converter"
    autoload :Cleanup, "metanorma/jis/cleanup"
    autoload :Validate, "metanorma/jis/validate"
    autoload :Processor, "metanorma/jis/processor"
    autoload :Front, "metanorma/jis/front"
    autoload :Log, "metanorma/jis/log"
    autoload :Document, "metanorma/jis/document"
    autoload :CitationStyle, "metanorma/jis/citation_style"
    autoload :JisElements, "metanorma/jis/jis_elements"
    autoload :VERSION, "metanorma/jis/version"
  end
end
