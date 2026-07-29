require "isodoc"
require "metanorma-iso"

module IsoDoc
  module Jis
    autoload :BaseConvert, "isodoc/jis/base_convert"
    autoload :HtmlConvert, "isodoc/jis/html_convert"
    autoload :PdfConvert, "isodoc/jis/pdf_convert"
    autoload :PresentationXMLConvert, "isodoc/jis/presentation_xml_convert"
    autoload :PresentationSection, "isodoc/jis/presentation_section"
    autoload :PresentationList, "isodoc/jis/presentation_list"
    autoload :PresentationTable, "isodoc/jis/presentation_table"
    autoload :Metadata, "isodoc/jis/metadata"
    autoload :Xref, "isodoc/jis/xref"
    autoload :I18n, "isodoc/jis/i18n"
    autoload :Init, "isodoc/jis/init"
    autoload :Docx, "isodoc/jis/docx"
  end
end
