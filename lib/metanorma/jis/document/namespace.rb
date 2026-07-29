# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Jis
    module Document
      # XML namespace for JIS documents. Used by the Root model's xml do
      # block (lutaml-model 0.8+ requires a Namespace subclass, not a string).
      class Namespace < Lutaml::Xml::Namespace
        uri "https://www.metanorma.org/ns/jis"
        prefix_default "jis"
        element_form_default :qualified
      end
    end
  end
end
