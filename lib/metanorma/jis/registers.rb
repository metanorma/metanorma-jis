# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Jis
    # JIS's lutaml-model register: creates the :jis_document context with
    # the ISO document register as fallback. Formerly
    # Metanorma::Registers::Setup.setup_jis_register in metanorma-
    # document; the substitution lives with the classes it names.
    module Registers
      module_function

      def setup
        iso = Metanorma::Iso::Document
        jis = Metanorma::Jis::Document
        reg = Lutaml::Model::Register.new(:jis_document,
                                          fallback: [:iso_document])
        Lutaml::Model::GlobalRegister.register(reg)

        reg.register_global_type_substitution(
          from_type: iso::Sections::IsoAnnexSection,
          to_type: jis::Sections::JisAnnexSection,
        )
      end
    end
  end
end
