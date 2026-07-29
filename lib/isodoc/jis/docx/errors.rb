# frozen_string_literal: true

module IsoDoc
  module Jis
    module Docx
      module Errors
        class DocxError < StandardError; end
        class UnknownDoctypeError < DocxError; end
        class UnknownStyleError < DocxError; end
        class MissingTemplateError < DocxError; end
        class RenderError < DocxError; end
      end
    end
  end
end
