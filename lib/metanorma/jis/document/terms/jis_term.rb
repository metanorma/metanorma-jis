# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Jis
    module Document
      module Terms
        # JIS term — inherits ISO term structure; JIS-specific admitted /
        # deprecated / alt containers are already standard in the parent.
        # Subclassed for dispatch: when the Adapter encounters a JIS term,
        # it routes to the JIS-aware renderer if one is registered.
        class JisTerm < Metanorma::IsoDocument::Terms::IsoTerm
          xml do
            element "term"
            ordered
          end
        end
      end
    end
  end
end
