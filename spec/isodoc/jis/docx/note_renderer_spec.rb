# frozen_string_literal: true

require "spec_helper"
require "isodoc/jis"
require "uniword"
require "metanorma/document"

RSpec.describe IsoDoc::Jis::Docx::Renderers::NoteRenderer do
  let(:doc) { Uniword::Builder::DocumentBuilder.new }
  let(:resolver) { IsoDoc::Jis::Docx::StyleResolver.new }

  let(:note_block) do
    Metanorma::Document::Components::Blocks::NoteBlock.from_hash(
      "content" => [{ "text" => ["Note body text"] }],
    )
  end

  it "renders the note with its content paragraphs" do
    described_class.new(doc: doc, resolver: resolver).render(note_block)
    texts = doc.model.body.paragraphs.flat_map do |p|
      p.runs.flat_map { |r| Array(r.text).map(&:content) }
    end.compact
    expect(texts.join).to include("注記")
    expect(texts.join).to include("Note body text")
  end
end
