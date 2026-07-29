# frozen_string_literal: true

require "spec_helper"
require "isodoc/jis"
require "uniword"
require "tmpdir"

RSpec.describe IsoDoc::Jis::Docx::Adapter do
  let(:fixture_xml) { File.read(File.expand_path("../../../fixtures/jis_sample.xml", __dir__)) }
  let(:output_path) { File.join(Dir.mktmpdir, "jis.docx") }

  before(:all) do
    @adapter = described_class.new
    @output = File.join(Dir.mktmpdir, "jis_all.docx")
    xml = File.read(File.expand_path("../../../../fixtures/jis_sample.xml", __FILE__))
    @adapter.convert(xml, @output)
    @doc = Uniword::DocumentFactory.from_file(@output)
  end

  it "produces a valid .docx file" do
    expect(File.exist?(@output)).to be(true)
    expect(File.size(@output)).to be > 1000
  end

  it "opens via Uniword::DocumentFactory.from_file" do
    expect(@doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
  end

  it "contains the JIS template's 600+ styles" do
    expect(@doc.styles_configuration.styles.size).to be > 600
  end

  it "contains body paragraphs with cover content" do
    texts = @doc.body.paragraphs.flat_map do |p|
      p.runs.flat_map { |r| Array(r.text).map(&:content) }
    end.compact
    expect(texts.join).to include("日本工業規格")
  end

  it "has headers from the template" do
    expect(@doc.headers.size).to be > 0
  end

  it "has footers from the template" do
    expect(@doc.footers.size).to be > 0
  end
end
