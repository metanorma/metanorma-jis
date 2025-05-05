require "spec_helper"
RSpec.describe Metanorma::Jis do
  before do
    # Force to download Relaton index file
    allow_any_instance_of(Relaton::Index::Type).to receive(:actual?)
      .and_return(false)
    allow_any_instance_of(Relaton::Index::FileIO).to receive(:check_file)
      .and_return(nil)
  end

  it "has a version number" do
    expect(Metanorma::Jis::VERSION).not_to be nil
  end

  it "accepts language = jp" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :language: jp
      :docnumber: 1000
    INPUT
    expect(xml.at("//xmlns:bibdata/xmlns:language").text)
      .to be_equivalent_to "ja"
  end

  it "defaults to language = ja" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docnumber: 1000
    INPUT
    expect(xml.at("//xmlns:bibdata/xmlns:language").text)
      .to be_equivalent_to "ja"
  end

  it "processes default metadata" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :docseries: Z
      :partnumber: 1
      :edition: 2
      :revdate: 2000-01-01
      :draft: 0.3.4
      :announced-date: 2000-02-01
      :technical-committee: TC
      :technical-committee-number: 1
      :technical-committee-type: A
      :subcommittee: SC
      :subcommittee-number: 2
      :subcommittee-type: B
      :workgroup: WG
      :workgroup-number: 3
      :workgroup-type: C
      :technical-committee_2: TC1
      :technical-committee-number_2: 11
      :technical-committee-type_2: A1
      :subcommittee_2: SC1
      :subcommittee-number_2: 21
      :subcommittee-type_2: B1
      :workgroup_2: WG1
      :workgroup-number_2: 31
      :workgroup-type_2: C1
      :secretariat: SECRETARIAT
      :approval-technical-committee: TCa
      :approval-technical-committee-number: 1a
      :approval-technical-committee-type: Aa
      :approval-subcommittee: SCa
      :approval-subcommittee-number: 2a
      :approval-subcommittee-type: Ba
      :approval-workgroup: WGa
      :approval-workgroup-number: 3a
      :approval-workgroup-type: Ca
      :approval-technical-committee_2: TC1a
      :approval-technical-committee-number_2: 11a
      :approval-technical-committee-type_2: A1a
      :approval-subcommittee_2: SC1a
      :approval-subcommittee-number_2: 21a
      :approval-subcommittee-type_2: B1a
      :approval-workgroup_2: WG1a
      :approval-workgroup-number_2: 31a
      :approval-workgroup-type_2: C1a
      :approval-agency: ISO/IEC
      :docstage: 20
      :docsubstage: 20
      :iteration: 3
      :title-intro-en: Introduction
      :title-main-en: Main Title -- Title
      :title-part-en: Title Part
      :title-intro-ja: Introduction Française
      :title-main-ja: Titre Principal
      :title-part-ja: Part du Titre
      :copyright-year: 2000
      :horizontal: true
      :investigative-organization-ja: 日本産業標準調査会
      :investigative-organization-en: Japanese Industrial Standards Committee
      :investigative-committee: 日本産業標準調査会 標準第一部会
    INPUT
    output = <<~OUTPUT
      <metanorma type="semantic" version="#{Metanorma::Jis::VERSION}" xmlns="https://www.metanorma.org/ns/standoc" flavor="jis">
               <bibdata type="standard">
           <title language="en" format="text/plain" type="main">Introduction — Main Title — Title — Title Part</title>
           <title language="en" format="text/plain" type="title-intro">Introduction</title>
           <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
           <title language="en" format="text/plain" type="title-part">Title Part</title>
           <title language="ja" format="text/plain" type="main">Introduction Française — Titre Principal — Part du Titre</title>
           <title language="ja" format="text/plain" type="title-intro">Introduction Française</title>
           <title language="ja" format="text/plain" type="title-main">Titre Principal</title>
           <title language="ja" format="text/plain" type="title-part">Part du Titre</title>
           <docidentifier primary="true" type="JIS">Z 1000-1:2000</docidentifier>
           <docnumber>1000</docnumber>
           <date type="announced">
              <on>2000-02-01</on>
           </date>
           <contributor>
             <role type="author"/>
             <organization>
               <name language="ja">日本工業規格</name>
               <name language="en">Japanese Industrial Standards</name>
               <abbreviation>JIS</abbreviation>
             </organization>
           </contributor>
           <contributor>
             <role type="publisher"/>
             <organization>
                  <name language="ja">日本工業規格</name>
                  <name language="en">Japanese Industrial Standards</name>
               <abbreviation>JIS</abbreviation>
             </organization>
           </contributor>
                      <contributor>
             <role type="authorizer">
               <description>Investigative organization</description>
             </role>
             <organization>
                 <name language="ja">日本産業標準調査会</name>
                 <name language="en">Japanese Industrial Standards Committee</name>
             </organization>
           </contributor>
           <contributor>
             <role type="authorizer">
               <description>Investigative committee</description>
             </role>
             <organization>
               <name>日本産業標準調査会 標準第一部会</name>
             </organization>
           </contributor>
           <edition>2</edition>
           <version>
             <revision-date>2000-01-01</revision-date>
             <draft>0.3.4</draft>
           </version>
           <language>ja</language>
           <script>Jpan</script>
           <status>
             <stage>20</stage>
             <substage>20</substage>
             <iteration>3</iteration>
           </status>
           <copyright>
             <from>2000</from>
             <owner>
               <organization>
            <name language="ja">日本工業規格</name>
            <name language="en">Japanese Industrial Standards</name>
                 <abbreviation>JIS</abbreviation>
               </organization>
             </owner>
           </copyright>
           <ext>
             <doctype>japanese-industrial-standard</doctype>
             <flavor>jis</flavor>
             <horizontal>true</horizontal>
             <editorialgroup>
               <agency>JIS</agency>
               <technical-committee number="1" type="A">TC</technical-committee>
               <technical-committee number="11" type="A1">TC1</technical-committee>
               <subcommittee number="2" type="B">SC</subcommittee>
               <subcommittee number="21" type="B1">SC1</subcommittee>
               <workgroup number="3" type="C">WG</workgroup>
               <workgroup number="31" type="C1">WG1</workgroup>
               <secretariat>SECRETARIAT</secretariat>
             </editorialgroup>
             <approvalgroup>
               <agency>ISO</agency>
               <agency>IEC</agency>
               <technical-committee number="1a" type="Aa">TCa</technical-committee>
               <technical-committee number="11a" type="A1a">TC1a</technical-committee>
               <subcommittee number="2a" type="Ba">SCa</subcommittee>
               <subcommittee number="21a" type="B1a">SC1a</subcommittee>
               <workgroup number="3a" type="Ca">WGa</workgroup>
               <workgroup number="31a" type="C1a">WG1a</workgroup>
             </approvalgroup>
             <structuredidentifier>
               <project-number part="1">1000</project-number>
             </structuredidentifier>
           </ext>
         </bibdata>
         <boilerplate>
           <copyright-statement>
             <p id="_">主 務 大 臣:経済産業大臣 制定:昭和 26.10.31 改正:平成十二年1月1日</p>
             <p id="_">官 報 掲 載 日:平成十二年2月1日</p>
             <p id="_">原 案 作 成 者:一般財団法人日本規格協会</p>
             <p id="_">(〒108-0073 東京都港区三田 3-13-12 三田 MT ビル TEL 03-4231-8530)</p>
             <p id="_">審 議 部 会:日本産業標準調査会日本産業標準調査会 標準第一部会</p>
           </copyright-statement>
           <feedback-statement>
             <p id="_">この規格についての意見又は質問は，上記原案作成者又は経済産業省産業技術環境局 国際標準課(〒100-8901 東京 都千代田区霞が関 1-3-1)にご連絡ください。</p>
             <p id="_">なお，日本産業規格は，産業標準化法の規定によって，少なくとも 5 年を経過する日までに日本産業標準調査会の審 議に付され，速やかに，確認，改正又は廃止されます。</p>
           </feedback-statement>
         </boilerplate>
         <sections> </sections>
       </metanorma>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
    xml.at("//xmlns:metanorma-extension")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
    xml = Nokogiri::XML(Asciidoctor.convert(
                          input.sub(":docfile: test.adoc",
                                    ":docfile: test.adoc\n:language: en"),
                          *OPTIONS,
                        ))
    xml.at("//xmlns:metanorma-extension")&.remove
    output = <<~OUTPUT
      <metanorma type="semantic" version="#{Metanorma::Jis::VERSION}" xmlns="https://www.metanorma.org/ns/standoc" flavor="jis">
               <bibdata type="standard">
           <title language="en" format="text/plain" type="main">Introduction — Main Title — Title — Title Part</title>
           <title language="en" format="text/plain" type="title-intro">Introduction</title>
           <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
           <title language="en" format="text/plain" type="title-part">Title Part</title>
           <title language="ja" format="text/plain" type="main">Introduction Française — Titre Principal — Part du Titre</title>
           <title language="ja" format="text/plain" type="title-intro">Introduction Française</title>
           <title language="ja" format="text/plain" type="title-main">Titre Principal</title>
           <title language="ja" format="text/plain" type="title-part">Part du Titre</title>
           <docidentifier primary="true" type="JIS">Z 1000-1:2000(E)</docidentifier>
           <docnumber>1000</docnumber>
           <date type="announced">
              <on>2000-02-01</on>
           </date>
           <contributor>
             <role type="author"/>
             <organization>
                  <name language="ja">日本工業規格</name>
                  <name language="en">Japanese Industrial Standards</name>
               <abbreviation>JIS</abbreviation>
             </organization>
           </contributor>
           <contributor>
             <role type="publisher"/>
             <organization>
                  <name language="ja">日本工業規格</name>
                  <name language="en">Japanese Industrial Standards</name>
               <abbreviation>JIS</abbreviation>
             </organization>
           </contributor>
                      <contributor>
             <role type="authorizer">
               <description>Investigative organization</description>
             </role>
             <organization>
                 <name language="ja">日本産業標準調査会</name>
                 <name language="en">Japanese Industrial Standards Committee</name>
             </organization>
           </contributor>
           <contributor>
             <role type="authorizer">
               <description>Investigative committee</description>
             </role>
             <organization>
               <name>日本産業標準調査会 標準第一部会</name>
             </organization>
           </contributor>
           <edition>2</edition>
           <version>
             <revision-date>2000-01-01</revision-date>
             <draft>0.3.4</draft>
           </version>
           <language>en</language>
           <script>Latn</script>
           <status>
             <stage>20</stage>
             <substage>20</substage>
             <iteration>3</iteration>
           </status>
           <copyright>
             <from>2000</from>
             <owner>
               <organization>
            <name language="ja">日本工業規格</name>
            <name language="en">Japanese Industrial Standards</name>
                 <abbreviation>JIS</abbreviation>
               </organization>
             </owner>
           </copyright>
           <ext>
             <doctype>japanese-industrial-standard</doctype>
             <flavor>jis</flavor>
             <horizontal>true</horizontal>
             <editorialgroup>
               <agency>JIS</agency>
               <technical-committee number="1" type="A">TC</technical-committee>
               <technical-committee number="11" type="A1">TC1</technical-committee>
               <subcommittee number="2" type="B">SC</subcommittee>
               <subcommittee number="21" type="B1">SC1</subcommittee>
               <workgroup number="3" type="C">WG</workgroup>
               <workgroup number="31" type="C1">WG1</workgroup>
               <secretariat>SECRETARIAT</secretariat>
             </editorialgroup>
             <approvalgroup>
               <agency>ISO</agency>
               <agency>IEC</agency>
               <technical-committee number="1a" type="Aa">TCa</technical-committee>
               <technical-committee number="11a" type="A1a">TC1a</technical-committee>
               <subcommittee number="2a" type="Ba">SCa</subcommittee>
               <subcommittee number="21a" type="B1a">SC1a</subcommittee>
               <workgroup number="3a" type="Ca">WGa</workgroup>
               <workgroup number="31a" type="C1a">WG1a</workgroup>
             </approvalgroup>
             <structuredidentifier>
               <project-number part="1">1000</project-number>
             </structuredidentifier>
           </ext>
         </bibdata>
                  <boilerplate>
           <copyright-statement>
             <p id="_">Competent Minister: Minister of Economy, Trade and Industry Established: October 31, 1951 Revised: 2000-01-01
       Date of publication in the Official Gazette: 2000-02-01
       Draft creator: Japanese Standards Association
       (Mita MT Building, 3-13-12 Mita, Minato-ku, Tokyo 108-0073 Tel: 03-4231-8530)
       Investigative Working Group: Japanese Industrial Standards Committee 日本産業標準調査会 標準第一部会 </p>
           </copyright-statement>
           <feedback-statement>
             <p id="_">Any comments or questions regarding this standard should be directed to the above drafter or the International Standardization Division, Industrial Science and Technology Policy and Environment Bureau, Ministry of Economy, Trade and Industry (Tokyo 100-8901 Tokyo, Japan). Please contact 1-3-1 Kasumigaseki, Chiyoda-ku, Tokyo. In accordance with the provisions of the Industrial Standardization Law, Japanese Industrial Standards shall be reviewed by the Japan Industrial Standards Committee by the date when at least five years have passed. It will be put up for discussion and promptly confirmed, amended or repealed.</p>
           </feedback-statement>
         </boilerplate>
         <sections> </sections>
       </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes metadata, multilingual values" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :revdate: 2000-01-01
      :revdate-ja: Two Thousand, Jan 1
      :announced-date-ja: Two Thousand, Feb 1
      :publisher-ja: JAPANESE NAME PUBLISHER
      :publisher-en: English name publisher
      :publisher-abbr: Publisher Abbrev
    INPUT
    output = <<~OUTPUT
      <metanorma type="semantic" version="#{Metanorma::Jis::VERSION}" xmlns="https://www.metanorma.org/ns/standoc" flavor="jis">
               <bibdata type="standard">
           <docidentifier primary="true" type="JIS">1000:#{Date.today.year}</docidentifier>
           <docnumber>1000</docnumber>
           <contributor>
             <role type="author"/>
             <organization>
                 <name language="ja">JAPANESE NAME PUBLISHER</name>
                 <name language="en">English name publisher</name>
               <abbreviation>Publisher Abbrev</abbreviation>
             </organization>
           </contributor>
           <contributor>
             <role type="publisher"/>
             <organization>
                 <name language="ja">JAPANESE NAME PUBLISHER</name>
                 <name language="en">English name publisher</name>
               <abbreviation>Publisher Abbrev</abbreviation>
             </organization>
           </contributor>
           <version>
             <revision-date>2000-01-01</revision-date>
           </version>
           <language>ja</language>
           <script>Jpan</script>
           <status>
             <stage>60</stage>
             <substage>60</substage>
           </status>
           <copyright>
             <from>#{Date.today.year}</from>
             <owner>
               <organization>
                   <name language="ja">JAPANESE NAME PUBLISHER</name>
                   <name language="en">English name publisher</name>
                 <abbreviation>Publisher Abbrev</abbreviation>
               </organization>
             </owner>
           </copyright>
           <ext>
             <doctype>japanese-industrial-standard</doctype>
             <flavor>jis</flavor>
             <editorialgroup>
               <agency>Publisher Abbrev</agency>
             </editorialgroup>
             <approvalgroup>
               <agency>JIS</agency>
             </approvalgroup>
             <structuredidentifier>
               <project-number>1000</project-number>
             </structuredidentifier>
           </ext>
         </bibdata>
         <boilerplate>
           <copyright-statement>
             <p id="_">主 務 大 臣:経済産業大臣 制定:昭和 26.10.31 改正:平成十二年1月1日</p>
             <p id="_">官 報 掲 載 日:</p>
             <p id="_">原 案 作 成 者:一般財団法人日本規格協会</p>
             <p id="_">(〒108-0073 東京都港区三田 3-13-12 三田 MT ビル TEL 03-4231-8530)</p>
             <p id="_">審 議 部 会:JAPANESE NAME PUBLISHER</p>
           </copyright-statement>
           <feedback-statement>
             <p id="_">この規格についての意見又は質問は，上記原案作成者又は経済産業省産業技術環境局 国際標準課(〒100-8901 東京 都千代田区霞が関 1-3-1)にご連絡ください。</p>
             <p id="_">なお，日本産業規格は，産業標準化法の規定によって，少なくとも 5 年を経過する日までに日本産業標準調査会の審 議に付され，速やかに，確認，改正又は廃止されます。</p>
           </feedback-statement>
         </boilerplate>
         <sections> </sections>
      </metanorma>
    OUTPUT
    xml.at("//xmlns:metanorma-extension")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes metadata, technical report; personal role in investigative committee" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :doctype: technical-report
      :fullname: KUROSAWA Akira
      :role: authorizer
      :role-description: investigative committee
      :affiliation: Committee 123
      :fullname_2: MIFUNE Toshiro
      :role_2: authorizer
      :role-description_2: investigative committee
      :affiliation_2: Committee 123
      :contributor-position_2: lead actor
      :language: ja

    INPUT
    output = <<~OUTPUT
      <metanorma type="semantic" version="#{Metanorma::Jis::VERSION}" xmlns="https://www.metanorma.org/ns/standoc" flavor="jis">
         <bibdata type="standard">
           <docidentifier primary="true" type="JIS">TR 1000:#{Date.today.year}</docidentifier>
           <docnumber>1000</docnumber>
           <contributor>
             <role type="author"/>
             <organization>
                  <name language="ja">日本工業規格</name>
                  <name language="en">Japanese Industrial Standards</name>
               <abbreviation>JIS</abbreviation>
             </organization>
           </contributor>
           <contributor>
             <role type="publisher"/>
             <organization>
                  <name language="ja">日本工業規格</name>
                  <name language="en">Japanese Industrial Standards</name>
               <abbreviation>JIS</abbreviation>
             </organization>
           </contributor>
           <contributor>
             <role type="authorizer">
               <description>investigative committee</description>
             </role>
             <person>
               <name>
                 <completename>KUROSAWA Akira</completename>
               </name>
               <affiliation>
                 <organization>
                   <name>Committee 123</name>
                 </organization>
               </affiliation>
             </person>
           </contributor>
           <contributor>
             <role type="authorizer">
               <description>investigative committee</description>
             </role>
             <person>
               <name>
                 <completename>MIFUNE Toshiro</completename>
               </name>
               <affiliation>
                 <name>委員会長</name>
                 <name>lead actor</name>
                 <organization>
                   <name>Committee 123</name>
                 </organization>
               </affiliation>
             </person>
           </contributor>
           <language>ja</language>
           <script>Jpan</script>
           <status>
             <stage>60</stage>
             <substage>60</substage>
           </status>
           <copyright>
             <from>#{Date.today.year}</from>
             <owner>
               <organization>
            <name language="ja">日本工業規格</name>
            <name language="en">Japanese Industrial Standards</name>
                 <abbreviation>JIS</abbreviation>
               </organization>
             </owner>
           </copyright>
           <ext>
             <doctype>technical-report</doctype>
             <flavor>jis</flavor>
             <editorialgroup>
               <agency>JIS</agency>
             </editorialgroup>
             <approvalgroup>
               <agency>JIS</agency>
             </approvalgroup>
             <structuredidentifier>
               <project-number>1000</project-number>
             </structuredidentifier>
           </ext>
         </bibdata>
         <boilerplate>
           <copyright-statement>
             <p id="_">主 務 大 臣:経済産業大臣 制定:昭和 26.10.31 改正:</p>
             <p id="_">官 報 掲 載 日:</p>
             <p id="_">原 案 作 成 者:一般財団法人日本規格協会</p>
             <p id="_">(〒108-0073 東京都港区三田 3-13-12 三田 MT ビル TEL 03-4231-8530)</p>
             <p id="_">審 議 部 会:日本工業規格Committee 123(委員会長 KUROSAWA Akira)</p>
           </copyright-statement>
           <feedback-statement>
             <p id="_">この規格についての意見又は質問は，上記原案作成者又は経済産業省産業技術環境局 国際標準課(〒100-8901 東京 都千代田区霞が関 1-3-1)にご連絡ください。</p>
             <p id="_">なお，日本産業規格は，産業標準化法の規定によって，少なくとも 5 年を経過する日までに日本産業標準調査会の審 議に付され，速やかに，確認，改正又は廃止されます。</p>
           </feedback-statement>
         </boilerplate>
         <sections> </sections>
       </metanorma>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
    xml.at("//xmlns:metanorma-extension")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
    xml = Nokogiri::XML(Asciidoctor.convert(input
      .sub(":language: ja", ":language: en"), *OPTIONS))
    xml = xml.at("//xmlns:boilerplate")
    output = <<~OUTPUT
      <boilerplate>
           <copyright-statement>
           <p id="_">Competent Minister: Minister of Economy, Trade and Industry Established: October 31, 1951 Revised: Date of publication in the Official Gazette: Draft creator: Japanese Standards Association (Mita MT Building, 3-13-12 Mita, Minato-ku, Tokyo 108-0073 Tel: 03-4231-8530) Investigative Working Group: Japanese Industrial Standards Committee 123 (Chairperson: KUROSAWA Akira)</p>
           </copyright-statement>
           <feedback-statement>
             <p id="_">Any comments or questions regarding this standard should be directed to the above drafter or the International Standardization Division, Industrial Science and Technology Policy and Environment Bureau, Ministry of Economy, Trade and Industry (Tokyo 100-8901 Tokyo, Japan). Please contact 1-3-1 Kasumigaseki, Chiyoda-ku, Tokyo. In accordance with the provisions of the Industrial Standardization Law, Japanese Industrial Standards shall be reviewed by the Japan Industrial Standards Committee by the date when at least five years have passed. It will be put up for discussion and promptly confirmed, amended or repealed.</p>
           </feedback-statement>
         </boilerplate>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes metadata, technical specification" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :doctype: technical-specification
    INPUT
    output = <<~OUTPUT
      <metanorma type="semantic" version="#{Metanorma::Jis::VERSION}" xmlns="https://www.metanorma.org/ns/standoc" flavor="jis">
         <bibdata type="standard">
           <docidentifier primary="true" type="JIS">TS 1000:#{Date.today.year}</docidentifier>
           <docnumber>1000</docnumber>
           <contributor>
             <role type="author"/>
             <organization>
                  <name language="ja">日本工業規格</name>
                  <name language="en">Japanese Industrial Standards</name>
               <abbreviation>JIS</abbreviation>
             </organization>
           </contributor>
           <contributor>
             <role type="publisher"/>
             <organization>
                  <name language="ja">日本工業規格</name>
                  <name language="en">Japanese Industrial Standards</name>
               <abbreviation>JIS</abbreviation>
             </organization>
           </contributor>
           <language>ja</language>
           <script>Jpan</script>
           <status>
             <stage>60</stage>
             <substage>60</substage>
           </status>
           <copyright>
             <from>#{Date.today.year}</from>
             <owner>
               <organization>
            <name language="ja">日本工業規格</name>
            <name language="en">Japanese Industrial Standards</name>
                 <abbreviation>JIS</abbreviation>
               </organization>
             </owner>
           </copyright>
           <ext>
             <doctype>technical-specification</doctype>
             <flavor>jis</flavor>
             <editorialgroup>
               <agency>JIS</agency>
             </editorialgroup>
             <approvalgroup>
               <agency>JIS</agency>
             </approvalgroup>
             <structuredidentifier>
               <project-number>1000</project-number>
             </structuredidentifier>
           </ext>
         </bibdata>
         <sections> </sections>
       </metanorma>
    OUTPUT
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes metadata, unrecognised type" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docidentifier: JIS EXP
      :docnumber: 1000
      :partnumber: 1
      :edition: 2
      :revdate: 2000-01-01
      :draft: 0.3.4
      :technical-committee: TC
      :technical-committee-number: 1
      :technical-committee-type: A
      :subcommittee: SC
      :subcommittee-number: 2
      :subcommittee-type: B
      :workgroup: WG
      :workgroup-number: 3
      :workgroup-type: C
      :technical-committee_2: TC1
      :technical-committee-number_2: 11
      :technical-committee-type_2: A1
      :subcommittee_2: SC1
      :subcommittee-number_2: 21
      :subcommittee-type_2: B1
      :workgroup_2: WG1
      :workgroup-number_2: 31
      :workgroup-type_2: C1
      :secretariat: SECRETARIAT
      :approval-technical-committee: TCa
      :approval-technical-committee-number: 1a
      :approval-technical-committee-type: Aa
      :approval-subcommittee: SCa
      :approval-subcommittee-number: 2a
      :approval-subcommittee-type: Ba
      :approval-workgroup: WGa
      :approval-workgroup-number: 3a
      :approval-workgroup-type: Ca
      :approval-technical-committee_2: TC1a
      :approval-technical-committee-number_2: 11a
      :approval-technical-committee-type_2: A1a
      :approval-subcommittee_2: SC1a
      :approval-subcommittee-number_2: 21a
      :approval-subcommittee-type_2: B1a
      :approval-workgroup_2: WG1a
      :approval-workgroup-number_2: 31a
      :approval-workgroup-type_2: C1a
      :approval-agency: ISO/IEC
      :docstage: 20
      :docsubstage: 20
      :iteration: 3
      :title-intro-en: Introduction
      :title-main-en: Main Title -- Title
      :title-part-en: Title Part
      :title-intro-ja: Introduction Française
      :title-main-ja: Titre Principal
      :title-part-ja: Part du Titre
      :copyright-year: 2000
      :horizontal: true
      :doctype: expert-commentary
      :author: 三船 敏郎
      :publisher: Alternative Publisher
      :copyright-holder: Copyright Holder
    INPUT
    output = <<~OUTPUT
          <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Jis::VERSION}" flavor="jis">
        <bibdata type="standard">
          <title language="en" format="text/plain" type="main">Introduction — Main Title — Title — Title Part</title>
          <title language="en" format="text/plain" type="title-intro">Introduction</title>
          <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
          <title language="en" format="text/plain" type="title-part">Title Part</title>
          <title language="ja" format="text/plain" type="main">Introduction Française — Titre Principal — Part du Titre</title>
          <title language="ja" format="text/plain" type="title-intro">Introduction Française</title>
          <title language="ja" format="text/plain" type="title-main">Titre Principal</title>
          <title language="ja" format="text/plain" type="title-part">Part du Titre</title>
          <docidentifier primary="true" type="JIS">EXP</docidentifier>
          <docnumber>1000</docnumber>
          <contributor>
            <role type="author"/>
            <organization>
              <name>Alternative Publisher</name>
            </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>Alternative Publisher</name>
            </organization>
          </contributor>
          <edition>2</edition>
          <version>
            <revision-date>2000-01-01</revision-date>
            <draft>0.3.4</draft>
          </version>
          <language>ja</language>
          <script>Jpan</script>
          <status>
            <stage>20</stage>
            <substage>20</substage>
            <iteration>3</iteration>
          </status>
          <copyright>
            <from>2000</from>
            <owner>
              <organization>
                <name>Copyright Holder</name>
              </organization>
            </owner>
          </copyright>
          <ext>
            <doctype>expert-commentary</doctype>
             <flavor>jis</flavor>
            <horizontal>true</horizontal>
            <editorialgroup>
              <agency>Alternative Publisher</agency>
              <technical-committee number="1" type="A">TC</technical-committee>
              <technical-committee number="11" type="A1">TC1</technical-committee>
              <subcommittee number="2" type="B">SC</subcommittee>
              <subcommittee number="21" type="B1">SC1</subcommittee>
              <workgroup number="3" type="C">WG</workgroup>
              <workgroup number="31" type="C1">WG1</workgroup>
              <secretariat>SECRETARIAT</secretariat>
            </editorialgroup>
            <approvalgroup>
              <agency>ISO</agency>
              <agency>IEC</agency>
              <technical-committee number="1a" type="Aa">TCa</technical-committee>
              <technical-committee number="11a" type="A1a">TC1a</technical-committee>
              <subcommittee number="2a" type="Ba">SCa</subcommittee>
              <subcommittee number="21a" type="B1a">SC1a</subcommittee>
              <workgroup number="3a" type="Ca">WGa</workgroup>
              <workgroup number="31a" type="C1a">WG1a</workgroup>
            </approvalgroup>
            <structuredidentifier>
              <project-number part="1">1000</project-number>
            </structuredidentifier>
          </ext>
        </bibdata>
        <sections> </sections>
      </metanorma>
    OUTPUT
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes metadata, amendment" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :doctype: amendment
      :created-date: 1999-01-01
      :amendment-number: 3
      :updates: JIS Z 1000-1:1980
      :copyright-year: 2022
    INPUT
    output = <<~OUTPUT
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Jis::VERSION}" flavor="jis">
                   <bibdata type="standard">
           <docidentifier primary="true" type="JIS">Z 1000-1:1980/AMD 3:2022</docidentifier>
           <docnumber>1000</docnumber>
           <date type="created">
             <on>1999-01-01</on>
           </date>
           <contributor>
             <role type="author"/>
             <organization>
                  <name language="ja">日本工業規格</name>
                  <name language="en">Japanese Industrial Standards</name>
               <abbreviation>JIS</abbreviation>
             </organization>
           </contributor>
           <contributor>
             <role type="publisher"/>
             <organization>
                  <name language="ja">日本工業規格</name>
                  <name language="en">Japanese Industrial Standards</name>
               <abbreviation>JIS</abbreviation>
             </organization>
           </contributor>
           <language>ja</language>
           <script>Jpan</script>
           <status>
             <stage>60</stage>
             <substage>60</substage>
           </status>
           <copyright>
             <from>2022</from>
             <owner>
               <organization>
            <name language="ja">日本工業規格</name>
            <name language="en">Japanese Industrial Standards</name>
                 <abbreviation>JIS</abbreviation>
               </organization>
             </owner>
           </copyright>
           <ext>
             <doctype>amendment</doctype>
             <flavor>jis</flavor>
             <editorialgroup>
               <agency>JIS</agency>
             </editorialgroup>
             <approvalgroup>
               <agency>JIS</agency>
             </approvalgroup>
             <structuredidentifier>
               <project-number amendment="3" origyr="1999-01-01">1000</project-number>
             </structuredidentifier>
           </ext>
         </bibdata>
         <sections> </sections>
       </metanorma>
    OUTPUT
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "preserves user-supplied boilerplate in Normative References" do
    VCR.use_cassette "isobib_216" do
      input = <<~INPUT
        #{ASCIIDOC_BLANK_HDR}
        [bibliography]
        == Normative References

        [NOTE,type=boilerplate]
        --
        This is extraneous information
        --

        * [[[iso216,ISO 216]]], _Reference_

        This is also extraneous information
      INPUT
      output = <<~OUTPUT
        #{BLANK_HDR}
        #{BOILERPLATE}
        <sections></sections>
                 <bibliography>
             <references id="_" anchor="_normative_references" normative="true" obligation="informative">
               <title>引用規格</title>
               <p id="_">This is extraneous information</p>
               <bibitem id="_" anchor="iso216" type="standard">
                 <title format="text/plain">Reference</title>
                 <docidentifier>ISO 216</docidentifier>
                 <docnumber>216</docnumber>
                 <contributor>
                   <role type="publisher"/>
                   <organization>
                     <name>International Organization for Standardization</name>
                     <abbreviation>ISO</abbreviation>
                   </organization>
                 </contributor>
               </bibitem>
               <p id="_">This is also extraneous information</p>
             </references>
           </bibliography>
        </standard-document>
      OUTPUT
      expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
        .to be_equivalent_to Xml::C14n.format(output)

      input = <<~INPUT
        #{ASCIIDOC_BLANK_HDR}
        [bibliography]
        == Normative References

        [.boilerplate]
        --
        This is extraneous information
        --

        * [[[iso216,ISO 216]]], _Reference_

        This is also extraneous information
      INPUT
      expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
        .to be_equivalent_to Xml::C14n.format(output)
    end
  end

  it "adds examples and notes both to tables" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      == Clause

      |===
      | A | B

      | C | B
      |===

      ====
      Example 1
      ====

      NOTE: Note 1

      ====
      Example 2
      ====

      ....
      hello?
      ....

      ====
      Example 3
      ====
    INPUT
    output = <<~OUTPUT
          #{BLANK_HDR}
      #{BOILERPLATE}
            <sections>
        <clause id="_" anchor="_clause" inline-header="false" obligation="normative">
          <title>Clause</title>
          <table id="_">
            <thead>
              <tr>
                <th id="_" valign="top" align="left">A</th>
                <th id="_" valign="top" align="left">B</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td id="_" valign="top" align="left">C</td>
                <td id="_" valign="top" align="left">B</td>
              </tr>
            </tbody>
          <example id="_">
            <p id="_">Example 1</p>
          </example>
          <note id="_">
            <p id="_">Note 1</p>
          </note>
          <example id="_">
            <p id="_">Example 2</p>
          </example>
          </table>
          <figure id="_">
            <pre id="_">hello?</pre>
          </figure>
          <example id="_">
            <p id="_">Example 3</p>
          </example>
        </clause>
      </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "respects keep-separate on examples" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      == Clause

      |===
      | A | B

      | C | B
      |===

      ====
      Example 1
      ====

      NOTE: Note 1

      [keep-separate=true]
      ====
      Example 2
      ====

      ....
      hello?
      ....

      ====
      Example 3
      ====
    INPUT
    output = <<~OUTPUT
          #{BLANK_HDR}
      #{BOILERPLATE}
            <sections>
        <clause id="_" anchor="_clause" inline-header="false" obligation="normative">
          <title>Clause</title>
          <table id="_">
            <thead>
              <tr>
                <th id="_" valign="top" align="left">A</th>
                <th id="_" valign="top" align="left">B</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td id="_" valign="top" align="left">C</td>
                <td id="_" valign="top" align="left">B</td>
              </tr>
            </tbody>
          <example id="_">
            <p id="_">Example 1</p>
          </example>
          <note id="_">
            <p id="_">Note 1</p>
          </note>
          </table>
          <example id="_">
            <p id="_">Example 2</p>
          </example>
          <figure id="_">
            <pre id="_">hello?</pre>
          </figure>
          <example id="_">
            <p id="_">Example 3</p>
          </example>
        </clause>
      </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "renumbers footnotes in tables (including table titles)" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      == Clause{blank}footnote:[Normal flow]

      .Table.footnote:[First]
      |===
      | A | B{blank}footnote:[Second]

      | C | B{blank}footnote:[Third]
      |===

      Paragraph.footnote:[Normal flow #2]
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
      #{BOILERPLATE}
               <sections>
           <clause id="_" anchor="_clausenormal_flow" inline-header="false" obligation="normative">
             <title>
               Clause
               <fn reference="1">
                 <p id="_">Normal flow</p>
               </fn>
             </title>
             <table id="_">
               <name>
                 Table.
                 <fn reference="a">
                   <p id="_">First</p>
                 </fn>
               </name>
               <thead>
                 <tr>
                   <th id="_" valign="top" align="left">A</th>
                   <th id="_" valign="top" align="left">
                     B
                     <fn reference="b">
                       <p id="_">Second</p>
                     </fn>
                   </th>
                 </tr>
               </thead>
               <tbody>
                 <tr>
                   <td id="_" valign="top" align="left">C</td>
                   <td id="_" valign="top" align="left">
                     B
                     <fn reference="c">
                       <p id="_">Third</p>
                     </fn>
                   </td>
                 </tr>
               </tbody>
             </table>
             <p id="_">
               Paragraph.
               <fn reference="2">
                 <p id="_">Normal flow #2</p>
               </fn>
             </p>
           </clause>
         </sections>
       </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes commentaries" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      [appendix]
      == First appendix

      [appendix%commentary]
      == Commentary
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
      #{BOILERPLATE}
      <sections/>
        <annex id="_" anchor="_first_appendix" inline-header="false" obligation="normative">
          <title>First appendix</title>
        </annex>
        <annex id="_" anchor="_commentary" commentary="true" inline-header="false" obligation="informative">
          <title>Commentary</title>
        </annex>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "ignores ordered list styles" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      [upperalpha]
      . First
      [upperroman]
      .. Second
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
      #{BOILERPLATE}
               <sections>
           <ol id="_">
             <li>
               <p id="_">First</p>
               <ol id="_">
                 <li>
                   <p id="_">Second</p>
                 </li>
               </ol>
             </li>
           </ol>
         </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
