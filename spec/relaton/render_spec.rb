require "spec_helper"
require "metanorma/jis/citation_style"
require "relaton/bib"

require_relative "../../lib/metanorma/jis/citation_style"

RSpec.describe Metanorma::Jis::CitationStyle do
  it "renders home standard, ISO" do
    input = <<~INPUT
      <bibitem type="standard" schema-version="v1.2.1">
              <fetched>2022-12-22</fetched>
        <title type="title-intro" format="text/plain" language="en" script="Latn">Latex, rubber</title>
        <title type="title-main" format="text/plain" language="en" script="Latn">Determination of total solids content</title>
        <title type="main" format="text/plain" language="en" script="Latn">Latex, rubber - Determination of total solids content</title>
        <title type="title-intro" format="text/plain" language="fr" script="Latn">Latex de caoutchouc</title>
        <title type="title-main" format="text/plain" language="fr" script="Latn">Détermination des matières solides totales</title>
        <title type="main" format="text/plain" language="fr" script="Latn">Latex de caoutchouc - Détermination des matières solides totales</title>
        <uri type="src">https://www.iso.org/standard/61884.html</uri>
        <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:61884:en</uri>
        <uri type="rss">https://www.iso.org/contents/data/standard/06/18/61884.detail.rss</uri>
        <docidentifier type="ISO" primary="true">ISO 124</docidentifier>
        <docidentifier type="URN">urn:iso:std:iso:124:ed-7</docidentifier>
        <docnumber>124</docnumber>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
            <uri>www.iso.org</uri>
          </organization>
        </contributor>
        <edition>7</edition>
        <language>en</language>
        <language>fr</language>
        <script>Latn</script>
        <status>
          <stage>90</stage>
          <substage>93</substage>
        </status>
        <copyright>
          <from>2014</from>
          <owner>
            <organization>
              <name>ISO</name>
            </organization>
          </owner>
        </copyright>
        <relation type="obsoletes">
          <bibitem type="standard">
            <formattedref format="text/plain">ISO 124:2011</formattedref>
            <docidentifier type="ISO" primary="true">ISO 124:2011</docidentifier>
          </bibitem>
        </relation>
        <place>Geneva</place>
        <ext schema-version="v1.0.0">
          <doctype>international-standard</doctype>
          <editorialgroup>
            <technical-committee number="45" type="TC">Raw materials (including latex) for use in the rubber industry</technical-committee>
          </editorialgroup>
          <ics>
            <code>83.040.10</code>
            <text>Latex and raw rubber</text>
          </ics>
          <structuredidentifier type="ISO">
            <project-number>ISO 124</project-number>
          </structuredidentifier>
        </ext>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref><span class="stddocTitle">Latex, rubber - Determination of total solids content</span></formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  let(:home_iso) do
    builder(type: "standard",
            titles: ["Latex, rubber - Determination of total solids content"],
            docids: { "ISO" => "ISO 124" },
            contribs: [{ role: [{ type: "publisher" }],
                         organization: { name: [{ content: "International Organization for Standardization" }] } }],
            dates: [], language: "en")
  end

  let(:book) do
    builder(type: "book",
            titles: ["Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday"],
            docids: { "ABC" => "ABC1" },
            contribs: [
              { role: [{ type: "editor" }],
                person: { name: { surname: "Aluffi", forename: "Paolo" } } },
              { role: [{ type: "editor" }],
                person: { name: { surname: "Aluffi", forename: "Paolo" } } },
              { role: [{ type: "editor" }],
                person: { name: { surname: "Aluffi", forename: "Paolo" } } },
              { role: [{ type: "publisher" }],
                organization: { name: [{ content: "Cambridge University Press" }] } },
            ],
            dates: [{ type: "published", from: "2022" }], edition: "1")
  end

  let(:home_jis) do
    builder(type: "standard",
            titles: ["電気及び関連分野―信号指定及び接続指定"],
            docids: { "JIS" => "JIS C 0450" },
            contribs: [{ role: [{ type: "publisher" }],
                         organization: { name: [{ content: "一般財団法人　日本規格協会" }] } }],
            dates: [], language: "ja")
  end

  let(:ietf) do
    builder(type: "standard",
            titles: ["Intellectual Property Rights in IETF Technology"],
            docids: { "IETF" => "RFC 3979" },
            contribs: [
              { role: [{ type: "editor" }],
                person: { name: { completename: { content: "S. Bradner" } } } },
              { role: [{ type: "authorizer" }],
                organization: { name: [{ content: "RFC Series" }] } },
            ],
            dates: [{ type: "published", from: "2005-03" }], language: "en")
  end

  it "generates generic citations" do
    input = <<~INPUT
      <references>
        <bibitem type="book" id="A">
          <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
          <docidentifier>ABC1</docidentifier>
          <date type="published"><on>2022</on></date>
          <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Aluffi</surname><forename>Paolo</forename></name>
            </person>
          </contributor>
          <edition>1</edition>
          <series>
          <title>London Mathematical Society Lecture Note Series</title>
          <number>472</number>
          </series>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>Cambridge University Press</name>
                </organization>
              </contributor>
              <place><formattedPlace>Cambridge, UK</formattedPlace></place>
            <size><value type="volume">1</value></size>
        </bibitem>
        <bibitem type="book" id="B">
          <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
          <docidentifier>ABC2</docidentifier>
          <date type="published"><on>2022</on></date>
          <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Aluffi</surname><forename>Paolo</forename></name>
            </person>
          </contributor>
          <edition>1</edition>
          <series>
          <title>London Mathematical Society Lecture Note Series</title>
          <number>472</number>
          </series>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>Cambridge University Press</name>
                </organization>
              </contributor>
              <place><formattedPlace>Cambridge, UK</formattedPlace></place>
            <size><value type="volume">1</value></size>
        </bibitem>
      </references>
    INPUT
    output = {"A" => {author: "Aluffi", date: "2022a", citation: {default: "ABC1", short: "Aluffi P. （編）<span class=\"fmt-first-biblio-delim\"/>。 Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday。第1版。（London Mathematical Society Lecture Note Series 472）。 Cambridge、 UK： Cambridge University Press。 2022。巻1", author_date: "Aluffi 2022", author_date_br: "Aluffi （2022）", author: "Aluffi", date: "2022", title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday", title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday", full: "Aluffi P. （編）。 Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday。第1版。（London Mathematical Society Lecture Note Series 472）。 Cambridge、 UK： Cambridge University Press。 2022。巻1"}, formattedref: "Aluffi P. （編）。 Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday。第1版。（London Mathematical Society Lecture Note Series 472）。 Cambridge、 UK： Cambridge University Press。 2022。巻1"}, "B" => {author: "Aluffi", date: "2022b", citation: {default: "ABC2", short: "Aluffi P. （編）<span class=\"fmt-first-biblio-delim\"/>。 Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday。第1版。（London Mathematical Society Lecture Note Series 472）。 Cambridge、 UK： Cambridge University Press。 2022。巻1", author_date: "Aluffi 2022", author_date_br: "Aluffi （2022）", author: "Aluffi", date: "2022", title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday", title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday", full: "Aluffi P. （編）。 Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday。第1版。（London Mathematical Society Lecture Note Series 472）。 Cambridge、 UK： Cambridge University Press。 2022。巻1"}, formattedref: "Aluffi P. （編）。 Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday。第1版。（London Mathematical Society Lecture Note Series 472）。 Cambridge、 UK： Cambridge University Press。 2022。巻1"}}
    p = renderer
    expect(p.render_all(input, type: nil))
      .to be_equivalent_to output
  end

  describe "#render" do
    it "renders home standard, ISO" do
      expect(ja.render(home_iso, embedded: true))
        .to eq("<span class='stddocTitle'>Latex, rubber - Determination of " \
               "total solids content</span>")
    end

    it "renders home standard, JIS" do
      expect(ja.render(home_jis, embedded: true))
        .to eq("<span class='stddocTitle'>電気及び関連分野―信号指定及び接続指定</span>")
    end

    it "renders external standard, IETF" do
      actual = ja.render(ietf, embedded: true)
      warn "[CI-DEBUG] ietf=#{actual.inspect}"
      expect(actual)
        .to eq("S. Bradner. <span class='stddocTitle'>Intellectual Property " \
               "Rights in IETF Technology</span>. RFC Series")
    end

    it "renders references with multiple authors, ja" do
      expect(ja.render(book, embedded: true))
        .to eq("Aluffi P., Aluffi P. 及び Aluffi P. (eds.) "                "_Facets of Algebraic Geometry: " \
               "A Collection in Honor of William Fulton's 80th Birthday_. " \
               "第1版. Cambridge, UK: Cambridge University Press. 2022")
    end

    it "renders references with multiple authors, en" do
      expect(en.render(book, embedded: true))
        .to eq("Aluffi P., Aluffi P. and Aluffi P. (eds.) "                "_Facets of Algebraic Geometry: "                "A Collection in Honor of William Fulton's 80th Birthday_. " \
               "第1版. Cambridge, UK: Cambridge University Press. 2022")
    end
  end

  describe "#render_all" do
    it "generates generic citations" do
      ret = ja.render_all([book])
      expect(ret[book.id][:citation][:default]).to eq("ABC1")
      expect(ret[book.id][:citation][:short]).to eq("Aluffi 2022")
    end
  end

  private

  def ja
    renderer
  end

  def en
    renderer_en
  end

  def builder(type:, titles:, docids: {}, contribs: [], dates: [], language: nil, edition: nil)
    docid_xml = docids.map { |t, i| %(<docidentifier type="#{t}">#{i}</docidentifier>) }.join
    contrib_xml = contribs.map do |c|
      role = Array(c[:role]).map { |r| %(<role type="#{r[:type]}"/>) }.join
      if c[:person]
        n = c[:person][:name]
        name = %(<name><surname>#{n[:surname]}</surname><forename>#{n[:forename]}</forename></name>) if n[:surname]
        name ||= %(<name><completename>#{n[:completename][:content]}</completename></name>)
        %(<contributor>#{role}<person>#{name}</person></contributor>)
      else
        names = Array(c[:organization][:name]).map { |n| %(<name>#{n[:content]}</name>) }.join
        %(<contributor>#{role}<organization>#{names}</organization></contributor>)
      end
    end.join
    dates_xml = dates.map { |d| %(<date type="#{d[:type]}"><from>#{d[:from]}</from></date>) }.join
    edition_xml = edition ? %(<edition>#{edition}</edition>) : ""
    lang_xml = language ? %(<language>#{language}</language>) : ""
    Relaton::Bib::Item.from_xml(<<~XML)
      <bibitem type="#{type}">
        #{titles.map { |t| %(<title format="text/plain">#{t}</title>) }.join}
        #{docid_xml}#{contrib_xml}#{dates_xml}#{edition_xml}#{lang_xml}
      </bibitem>
    XML
  end

  def renderer
    Metanorma::Jis::CitationStyle
      .new("language" => "ja", "script" => "Jpan",
           "i18nhash" => IsoDoc::Jis::PresentationXMLConvert.new({})
      .i18n_init("ja", "Jpan", nil).get)
  end

  def renderer_en
    Metanorma::Jis::CitationStyle
      .new("language" => "en", "script" => "Latn",
           "i18nhash" => IsoDoc::Jis::PresentationXMLConvert.new({})
      .i18n_init("en", "Latn", nil).get)
  end
end
