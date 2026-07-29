# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Jis
    module Document
      module Sections
        # 解説 (commentary) section — unique to JIS. Non-normative annex
        # appended after the body, with its own TOC, restart page
        # numbering at Arabic 1, distinct headers/footers ("解説" prefix).
        #
        # Subclasses StandardDocument::AnnexSection (the closest structural
        # match in the shared gem); adds JIS-specific commentary markers.
        # The Adapter's CommentaryRenderer handles the page-setup details
        # via the section's YAML (data/jis/sections/commentary.yml).
        class JisCommentarySection < Metanorma::StandardDocument::Sections::AnnexSection
          xml do
            element "commentary"
            ordered
          end
        end
      end
    end
  end
end
