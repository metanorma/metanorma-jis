# frozen_string_literal: true

require "spec_helper"
require "isodoc/jis"
require "uniword"
require "metanorma/document"

RSpec.describe IsoDoc::Jis::Docx::Renderers::TableRenderer do
  let(:doc) { Uniword::Builder::DocumentBuilder.new }
  let(:resolver) { IsoDoc::Jis::Docx::StyleResolver.new }

  let(:table_block) do
    Metanorma::Document::Components::Tables::TableBlock.from_hash(
      "thead" => { "tr" => [{ "th" => [{ "text" => ["Head"] }] }] },
      "tbody" => { "tr" => [{ "td" => [{ "text" => ["Body"] }] }] },
    )
  end

  it "renders the table with a 100% table width" do
    described_class.new(doc: doc, resolver: resolver).render(table_block)
    tbl = doc.model.body.tables.first
    expect(tbl.properties.table_width.w).to eq(5000)
    expect(tbl.properties.table_width.type).to eq("pct")
  end

  it "renders one row per thead and tbody row" do
    described_class.new(doc: doc, resolver: resolver).render(table_block)
    tbl = doc.model.body.tables.first
    expect(tbl.rows.size).to eq(2)
  end
end
