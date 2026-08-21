# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Jis
    # jis's lutaml-model register: type substitutions from standoc.
    # Formerly Metanorma::Registers::Setup.setup_jis_register in metanorma-document.
    module Registers
      module_function

      def setup
          iso = Metanorma::IsoDocument
          reg = Lutaml::Model::Register.new(:jis_document,
                                            fallback: [:iso_document])
          Lutaml::Model::GlobalRegister.register(reg)

          reg.register_global_type_substitution(
            from_type: iso::Sections::IsoAnnexSection,
            to_type: Metanorma::Jis::Document::Sections::JisAnnexSection,
          )
      end
    end
  end
end
