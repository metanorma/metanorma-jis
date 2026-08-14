# frozen_string_literal: true

require_relative "./jis/processor"
require "metanorma/jis/document"
module Metanorma
  module Jis
    autoload :CitationStyle, "metanorma/jis/citation_style"
    autoload :JisElements, "metanorma/jis/jis_elements"
  end
end
