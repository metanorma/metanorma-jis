require "spec_helper"
require "metanorma/jis/citation_style"
require "relaton/bib"

RSpec.describe Metanorma::Jis::CitationStyle do
  let(:home_jis_xml) do
    <<~XML
      <bibitem type="standard" id="h">
        <title type="main" language="ja">規格の参照方法</title>
        <docidentifier type="JIS">JIS Z 8401:2019</docidentifier>
        <date type="published"><on>2019</on></date>
        <language>ja</language>
        <script>Jpan</script>
      </bibitem>
    XML
  end

  let(:nonhome_xml) do
    <<~XML
      <bibitem type="standard" id="n">
        <title type="main">Data specification</title>
        <docidentifier type="IEEE">IEEE 1234</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization><name>Institute of Electrical and Electronics Engineers</name></organization>
        </contributor>
        <contributor>
          <role type="author"/>
          <organization><name>Institute of Electrical and Electronics Engineers</name></organization>
        </contributor>
        <date type="published"><on>2020</on></date>
        <language>en</language>
      </bibitem>
    XML
  end

  describe "#render" do
    it "renders a home JIS standard title-first in the stddocTitle span" do
      model = Relaton::Bib::Item.from_xml(home_jis_xml)
      expect(described_class.new(language: "ja").render(model, embedded: true))
        .to eq("<span class='stddocTitle'>規格の参照方法</span>")
    end

    it "renders a non-home standard with creator and issuing body" do
      model = Relaton::Bib::Item.from_xml(nonhome_xml)
      expect(described_class.new(language: "en").render(model, embedded: true))
        .to eq("Institute of Electrical and Electronics Engineers. " \
               "<span class='stddocTitle'>Data specification</span>, " \
               "Institute of Electrical and Electronics Engineers")
    end

    it "cites a home standard by year" do
      model = Relaton::Bib::Item.from_xml(home_jis_xml)
      expect(described_class.new(language: "ja").citation(model)).to eq("2019")
    end
  end

  describe "#render_all" do
    it "strips the terminal period from Japanese reference renderings" do
      style = described_class.new(language: "ja")
      ret = style.render_all("<references>#{home_jis_xml}</references>")
      expect(ret["h"][:formattedref])
        .to eq("<span class='stddocTitle'>規格の参照方法</span>")
    end
  end
end
