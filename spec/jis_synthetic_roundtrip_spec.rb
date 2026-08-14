# frozen_string_literal: true

require "bundler/setup"
require "rspec/matchers"
require "metanorma/jis/document"

RSpec.describe "JIS synthetic round-trip" do
  def round_trip(root_class, xml)
    doc = root_class.from_xml(xml)
    output = doc.to_xml
    reparsed = root_class.from_xml(output)
    [doc, reparsed, output]
  end

describe "JIS" do
  let(:xml) do
    <<~XML
      <metanorma type="semantic" version="1.0">
        <bibdata type="standard"><title>JIS Doc</title></bibdata>
        <sections>
          <clause id="_c1"><title>Scope</title><p>Text</p></clause>
        </sections>
        <annex id="_a1" obligation="informative" commentary="true">
          <title>Commentary</title>
          <clause id="_ac1"><title>Notes</title><p>Commentary text</p></clause>
        </annex>
      </metanorma>
    XML
  end

  it "parses the flavor root with its distinguishing features" do
    doc = Metanorma::Jis::Document::Root.from_xml(xml)
    expect(doc.annex.first)
      .to be_a(Metanorma::Jis::Document::Sections::JisAnnexSection)
    expect(doc.annex.first.commentary).to be(true)
    expect(doc.annex.first.clause.length).to eq(1)
  end

  it "round-trips the flavor-specific structures" do
    _, reparsed, output = round_trip(Metanorma::Jis::Document::Root, xml)
    expect(output).to include('commentary="true"')
    expect(reparsed.annex.first.commentary).to be(true)
    expect(reparsed.annex.first.clause.length).to eq(1)
  end
end
end
