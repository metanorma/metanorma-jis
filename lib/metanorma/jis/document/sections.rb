# frozen_string_literal: true

module Metanorma
  module Jis
    module Document
      module Sections
        autoload :JisClauseSection, "#{__dir__}/sections/jis_clause_section"
        autoload :JisAnnexSection, "#{__dir__}/sections/jis_annex_section"
        autoload :JisCommentarySection, "#{__dir__}/sections/jis_commentary_section"
        autoload :JisIndexSection, "#{__dir__}/sections/jis_index_section"
        autoload :JisSections, "#{__dir__}/sections/jis_sections"
      end
    end
  end
end
