# frozen_string_literal: true

require "spec_helper"
require "metanorma/jis/document"

RSpec.describe Metanorma::Jis::Document do
  describe "Root" do
    it "is a lutaml-model Serializable" do
      expect(described_class::Root.ancestors)
        .to include(Lutaml::Model::Serializable)
    end

    it "declares JIS-specific section attributes" do
      attrs = described_class::Root.attributes.keys.map(&:to_s)
      expect(attrs).to include("cover", "commentary", "index")
    end
  end

  describe "Cover" do
    it "accepts the JIS doctypes" do
      expect(described_class::Cover::JIS_DOCTYPES)
        .to include("japanese-industrial-standard", "technical-report",
                    "technical-specification", "amendment")
    end

    it "recognizes international alignment markers" do
      expect(described_class::Cover::INTERNATIONAL_ALIGNMENT)
        .to eq(%i[idt mod neq none])
    end

    describe "#dual_language?" do
      it "is true when both ja and en titles are present" do
        cover = described_class::Cover.new(title_ja: "日本語", title_en: "English")
        expect(cover.dual_language?).to be(true)
      end

      it "is false when only ja title is present" do
        cover = described_class::Cover.new(title_ja: "日本語")
        expect(cover.dual_language?).to be(false)
      end
    end

    describe "#amendment?" do
      it "is true for amendment doctype" do
        cover = described_class::Cover.new(doctype: "amendment")
        expect(cover.amendment?).to be(true)
      end

      it "is true for technical-corrigendum doctype" do
        cover = described_class::Cover.new(doctype: "technical-corrigendum")
        expect(cover.amendment?).to be(true)
      end

      it "is false for japanese-industrial-standard" do
        cover = described_class::Cover.new(doctype: "japanese-industrial-standard")
        expect(cover.amendment?).to be(false)
      end
    end
  end

  describe "Sections" do
    it "dispatches JisClauseSection as subclass of IsoClauseSection" do
      expect(described_class::Sections::JisClauseSection.ancestors)
        .to include(Metanorma::IsoDocument::Sections::IsoClauseSection)
    end

    it "marks JisAnnexSection with a commentary attribute" do
      expect(described_class::Sections::JisAnnexSection.attributes.keys)
        .to include(:commentary)
    end

    it "models JisCommentarySection as an AnnexSection subclass" do
      expect(described_class::Sections::JisCommentarySection.ancestors)
        .to include(Metanorma::StandardDocument::Sections::AnnexSection)
    end

    it "models JisIndexSection with dual-alphabet collections" do
      attrs = described_class::Sections::JisIndexSection.attributes.keys
      expect(attrs).to include(:kana_index, :latin_index)
    end
  end

  describe "Terms" do
    it "models JisTerm as a subclass of IsoTerm" do
      expect(described_class::Terms::JisTerm.ancestors)
        .to include(Metanorma::IsoDocument::Terms::IsoTerm)
    end
  end

  describe "Namespace" do
    it "uses the JIS namespace URI" do
      expect(described_class::Namespace.uri.to_s)
        .to eq("https://www.metanorma.org/ns/jis")
    end
  end
end
