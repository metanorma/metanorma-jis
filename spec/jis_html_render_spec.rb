# frozen_string_literal: true

# Self-contained: avoids the gem spec_helper's heavier requires.
require "bundler/setup"
require "metanorma/jis/document"
require "metanorma/jis/html"
require "metanorma/html/generator"

# The renderer registration contract: the JIS root and JIS annex must
# dispatch — an unregistered root renders reader chrome with no
# document body. (Real-fixture verification against mn-samples-jis
# JIS Z 5999 is documented in the PR: 116 paragraphs, 12 sections.)
RSpec.describe "Metanorma::Jis::Html::Renderer" do
  let(:xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" \
type="presentation" flavor="jis">
        <bibdata type="standard"><title>JIS Test</title></bibdata>
        <sections><clause id="_c1" obligation="normative">
          <title>Scope</title><p id="_p1">The scope.</p>
        </clause></sections>
      </metanorma>
    XML
  end

  it "renders the JIS root to a document body, not an empty shell" do
    model = Metanorma::Jis::Document::Root.from_xml(xml)
    html = Metanorma::Html::Generator.generate(model)
    page = Nokogiri::HTML(html)
    page.css("header, nav, .header-actions, button, kbd").remove

    expect(page.css("p").size).to be >= 1,
                                  "document body rendered no content (root dispatch missing)"
    expect(page.at("body").text).to include("The scope.")
  end

  it "is the renderer the flavor registry resolves" do
    entry = Metanorma::Core::Flavors.find(:jis)
    expect(entry.renderers[:html].call(nil)).to eq(Metanorma::Jis::Html::Renderer)
  end
end
