# frozen_string_literal: true

require "spec_helper"
require "isodoc/jis"
require "uniword"
require "metanorma/jis/document"
require "tmpdir"

FIXTURE = File.expand_path("fixtures/jis_sample.xml", __dir__)

RSpec.describe "JIS end-to-end pipeline", :e2e do
  it "Adapter produces a real .docx from the JIS fixture" do
    output = File.join(Dir.mktmpdir, "jis_e2e.docx")
    adapter = IsoDoc::Jis::Docx::Adapter.new
    adapter.convert(FIXTURE, output)
    expect(File.exist?(output)).to be(true)
    doc = Uniword::DocumentFactory.from_file(output)
    expect(doc.body.paragraphs.size).to be > 0
  end

  it "Root model parses sections from the fixture XML" do
    root = Metanorma::Jis::Document::Root.from_xml(File.read(FIXTURE))
    expect(root.sections).not_to be_nil
    expect(root.sections.clause.size).to be > 0
  end

  it "loads template.docx and style_mapping.yml" do
    sm = IsoDoc::Jis::Docx::StyleMapping
    expect(File.exist?(sm.template_path(:jis))).to be(true)
    expect(File.exist?(sm.style_mapping_path)).to be(true)
  end

  it "uses autoloaded classes with no require_relative" do
    expect(Metanorma::Jis::Document::Root).to be_a(Class)
    expect(IsoDoc::Jis::Docx::Adapter).to be_a(Class)
  end
end
