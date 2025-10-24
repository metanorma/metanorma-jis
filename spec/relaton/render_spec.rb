require "spec_helper"

RSpec.describe Relaton::Render::Jis do
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
      <formattedref><span class="stddocTitle">Latex、 rubber - Determination of total solids content</span></formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders home standard, JIS" do
    input = <<~INPUT
      <bibdata type="standard" schema-version="v1.2.9">
        <fetched>2024-07-29</fetched>
        <title format="text/plain" language="ja" script="Jpan">電気及び関連分野―信号指定及び接続指定</title>
        <title format="text/plain" language="en" script="Lant">Designations for signals and connections</title>
        <uri type="src">https://webdesk.jsa.or.jp/books/W11M0090/index/?bunsyo_id=JIS+C+0450%3A2004</uri>
        <uri type="pdf">https://webdesk.jsa.or.jp/preview/pre_jis_c_00450_000_000_2004_j_ed10_ch.pdf</uri>
        <docidentifier type="JIS" primary="true">JIS C 0450</docidentifier>
        <docnumber>C0450</docnumber>
        <contributor>
          <role type="author"/>
          <organization>
            <name language="ja" script="Jpan">一般財団法人　日本規格協会</name>
            <name language="en" script="Latn">Japanese Industrial Standards</name>
          </organization>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name language="ja" script="Jpan">一般財団法人　日本規格協会</name>
            <name language="en" script="Latn">Japanese Industrial Standards</name>
          </organization>
        </contributor>
        <language>ja</language>
        <script>Jpan</script>
        <status>
          <stage>valid</stage>
        </status>
        <relation type="instanceOf">
          <bibitem type="standard">
            <fetched>2024-07-29</fetched>
            <title format="text/plain" language="ja" script="Jpan">電気及び関連分野―信号指定及び接続指定</title>
            <title format="text/plain" language="en" script="Lant">Designations for signals and connections</title>
            <uri type="src">https://webdesk.jsa.or.jp/books/W11M0090/index/?bunsyo_id=JIS+C+0450%3A2004</uri>
            <uri type="pdf">https://webdesk.jsa.or.jp/preview/pre_jis_c_00450_000_000_2004_j_ed10_ch.pdf</uri>
            <docidentifier type="JIS" primary="true">JIS C 0450:2004</docidentifier>
            <docnumber>C0450</docnumber>
            <date type="issued">
              <on>2004-12-20</on>
            </date>
            <date type="confirmed">
              <on>2020-06-22</on>
            </date>
            <contributor>
              <role type="author"/>
              <organization>
                <name language="ja" script="Jpan">一般財団法人　日本規格協会</name>
                <name language="en" script="Latn">Japanese Industrial Standards</name>
              </organization>
            </contributor>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name language="ja" script="Jpan">一般財団法人　日本規格協会</name>
                <name language="en" script="Latn">Japanese Industrial Standards</name>
              </organization>
            </contributor>
            <language>ja</language>
            <script>Jpan</script>
            <abstract format="text/plain" language="ja" script="Jpan">電気及びその関連分野の信号及び接続を識別する指定並びに名称の組合せに関する規則について規定。</abstract>
            <status>
              <stage>valid</stage>
            </status>
          </bibitem>
        </relation>
        <ext schema-version="v0.0.1">
          <doctype>japanese-industrial-standard</doctype>
          <editorialgroup>
            <technical-committee>一般財団法人　日本規格協会</technical-committee>
          </editorialgroup>
          <ics>
            <code>29.020</code>
            <text>Electrical engineering in general</text>
          </ics>
          <structuredidentifier type="JIS">
            <docnumber/>
          </structuredidentifier>
        </ext>
      </bibdata>
    INPUT
    output = <<~OUTPUT
      <formattedref><span class='stddocTitle'>電気及び関連分野―信号指定及び接続指定</span></formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders external standard, IETF" do
    input = <<~INPUT
      <bibitem type="standard">
        <fetched>2022-12-22</fetched>
        <title type="main" format="text/plain">Intellectual Property Rights in IETF Technology</title>
        <uri type="src">https://www.rfc-editor.org/info/rfc3979</uri>
        <docidentifier type="IETF" primary="true">RFC 3979</docidentifier>
        <docidentifier type="DOI">10.17487/RFC3979</docidentifier>
        <docnumber>RFC3979</docnumber>
        <date type="published">
          <on>2005-03</on>
        </date>
        <contributor>
          <role type="editor"/>
          <person>
            <name>
              <completename language="en" script="Latn">S. Bradner</completename>
            </name>
          </person>
        </contributor>
        <contributor>
          <role type="authorizer"/>
          <organization>
            <name>RFC Series</name>
          </organization>
        </contributor>
        <language>en</language>
        <script>Latn</script>
        <abstract format="text/html" language="en" script="Latn">
          <p>The IETF policies about Intellectual Property Rights (IPR), such as patent rights, relative to technologies developed in the IETF are designed to ensure that IETF working groups and participants have as much information about any IPR constraints on a technical proposal as possible.  The policies are also intended to benefit the Internet community and the public at large, while respecting the legitimate rights of IPR holders.  This memo details the IETF policies concerning IPR related to technology worked on within the IETF.  It also describes the objectives that the policies are designed to meet.  This memo updates RFC 2026 and, with RFC 3978, replaces Section 10 of RFC 2026.  This memo also updates paragraph 4 of Section 3.2 of RFC 2028, for all purposes, including reference [2] in RFC 2418.  This document specifies an Internet Best Current Practices for the Internet Community, and requests discussion and suggestions for improvements.</p>
        </abstract>
        <relation type="obsoletedBy">
          <bibitem>
            <formattedref format="text/plain">RFC8179</formattedref>
            <docidentifier type="IETF" primary="true">RFC8179</docidentifier>
          </bibitem>
        </relation>
        <relation type="updates">
          <bibitem>
            <formattedref format="text/plain">RFC2026</formattedref>
            <docidentifier type="IETF" primary="true">RFC2026</docidentifier>
          </bibitem>
        </relation>
        <relation type="updates">
          <bibitem>
            <formattedref format="text/plain">RFC2028</formattedref>
            <docidentifier type="IETF" primary="true">RFC2028</docidentifier>
          </bibitem>
        </relation>
        <series>
          <title format="text/plain">RFC</title>
          <number>3979</number>
        </series>
        <keyword>ipr</keyword>
        <keyword>copyright</keyword>
        <ext schema-version="v1.0.0">
          <editorialgroup>
            <committee>ipr</committee>
          </editorialgroup>
        </ext>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>S. Bradner。 <span class="stddocTitle">Intellectual Property Rights in IETF Technology</span>。 RFC Series。入手先： <span class="biburl"><link target="https://www.rfc-editor.org/info/rfc3979">https://www.rfc-editor.org/info/rfc3979</link></span></formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
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
              <place>Cambridge, UK</place>
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
              <place>Cambridge, UK</place>
            <size><value type="volume">1</value></size>
        </bibitem>
      </references>
    INPUT
    output =
      {"A" => {author: "Aluffi", date: "2022a", citation: {default: "ABC1", short: "<esc>Aluffi</esc> <esc>P.</esc> (編). Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday. 第1版. (London Mathematical Society Lecture Note Series 472). Cambridge, UK: Cambridge University Press. 2022a. 巻1.", author_date: "Aluffi 2022a", author_date_br: "Aluffi (2022a)", author: "Aluffi", date: "2022a", reference_tag: nil, title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday", title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday"}, formattedref: "Aluffi P. （編）。 Facets of Algebraic Geometry： A Collection in Honor of William Fulton's 80th Birthday。第1版。（London Mathematical Society Lecture Note Series 472）。 Cambridge、 UK： Cambridge University Press。 2022a。巻1"},
       "B" => {author: "Aluffi", date: "2022b", citation: {default: "ABC2", short: "<esc>Aluffi</esc> <esc>P.</esc> (編). Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday. 第1版. (London Mathematical Society Lecture Note Series 472). Cambridge, UK: Cambridge University Press. 2022b. 巻1.", author_date: "Aluffi 2022b", author_date_br: "Aluffi (2022b)", author: "Aluffi", date: "2022b", reference_tag: nil, title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday", title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday"}, formattedref: "Aluffi P. （編）。 Facets of Algebraic Geometry： A Collection in Honor of William Fulton's 80th Birthday。第1版。（London Mathematical Society Lecture Note Series 472）。 Cambridge、 UK： Cambridge University Press。 2022b。巻1"}}
    p = renderer
    expect(p.render_all(input, type: nil))
      .to be_equivalent_to output
  end

  private

  def renderer
    Relaton::Render::Jis::General
      .new("language" => "ja", "script" => "Jpan",
           "i18nhash" => IsoDoc::Jis::PresentationXMLConvert.new({})
      .i18n_init("ja", "Jpan", nil).get)
  end
end
