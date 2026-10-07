require "spec_helper"
require "metanorma/jis/citation_style"
require "relaton/bib"

RSpec.describe Metanorma::Jis::CitationStyle do
  let(:home_jis_model) do
    described_class_builder(
      type: "standard",
      titles: ["規格の参照方法"],
      docids: { "JIS" => "JIS Z 8401:2019" },
      contribs: [{ role: [{ type: "publisher" }],
                   organization: { name: [{ content: "一般財団法人　日本規格協会" }] } }],
      dates: [{ type: "published", from: "2019" }],
      language: "ja",
    )
  end

  let(:home_jis_xml) do
    "<references>" + Relaton::Bib::Bibitem.from_yaml(home_jis_model.to_yaml).to_xml + "</references>"
  rescue StandardError
    home_jis_model
  end

  describe "#render" do
    it "renders a home JIS standard title-first in the stddocTitle span" do
      expect(described_class.new(language: "ja").render(home_jis_model, embedded: true))
        .to eq("<span class='stddocTitle'>規格の参照方法</span>")
    end

    it "renders a non-home standard with creator and issuing body" do
      model = described_class_builder(
        type: "standard",
        titles: ["Data specification"],
        docids: { "IEEE" => "IEEE 1234" },
        contribs: [
          { role: [{ type: "publisher" }],
            organization: { name: [{ content: "Institute of Electrical and Electronics Engineers" }] } },
          { role: [{ type: "author" }],
            organization: { name: [{ content: "Institute of Electrical and Electronics Engineers" }] } },
        ],
        dates: [{ type: "published", from: "2020" }],
      )
      expect(described_class.new(language: "en").render(model, embedded: true))
        .to eq("Institute of Electrical and Electronics Engineers. " \
               "<span class='stddocTitle'>Data specification</span>, " \
               "Institute of Electrical and Electronics Engineers")
    end

    it "cites a home standard by year" do
      actual = described_class.new(language: "ja").citation(home_jis_model)
      warn "[CI-DEBUG] citation=#{actual.inspect} date=#{home_jis_model.date.inspect}"
      expect(actual).to eq("2019")
    end
  end

  describe "#render_all" do
    it "strips the terminal period from Japanese reference renderings" do
      style = described_class.new(language: "ja")
      ret = style.render_all([home_jis_model])
      expect(ret[home_jis_model.id][:formattedref])
        .to eq("<span class='stddocTitle'>規格の参照方法</span>")
    end
  end

  private

  # Models are built directly: parsing the same XML yields different fields
  # per leptris platform build (leptris#1559), and these specs test rendering
  def described_class_builder(type:, titles:, docids:, contribs:, dates: [],
                              language: "en")
    Relaton::Bib::Item.new(
      id: "ref",
      type: type,
      title: titles.map { |t| { content: t, type: "main", language: language } },
      docidentifier: docids.map { |type_, content| { content: content, type: type_ } },
      contributor: contribs,
      date: dates,
      language: [language],
    )
  end
end
