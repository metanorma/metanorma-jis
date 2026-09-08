# frozen_string_literal: true

module Metanorma
  module Jis
    module Html
      # JIS documents render iso-style: the JIS root and annex
      # register alongside the ISO classes the parent renderer covers
      # (exact-class dispatch, OGC pattern).
      class Renderer < Metanorma::Iso::Html::Renderer
        register_render "Metanorma::Jis::Document::Root", :render_document
        register_render "Metanorma::Jis::Document::Sections::JisAnnexSection",
                        :render_annex
      end
    end
  end
end
