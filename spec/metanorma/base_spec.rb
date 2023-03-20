require "spec_helper"
RSpec.describe Metanorma::JIS do
  it "has a version number" do
    expect(Metanorma::JIS::VERSION).not_to be nil
  end

  it "accepts language = jp" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~"INPUT", *OPTIONS))
      = Document title
      Author
      :language: jp
    INPUT
    expect(xml.at("//xmlns:bibdata/xmlns:language").text)
      .to be_equivalent_to "ja"
  end

  it "defaults to language = ja" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~"INPUT", *OPTIONS))
      = Document title
      Author
    INPUT
    expect(xml.at("//xmlns:bibdata/xmlns:language").text)
      .to be_equivalent_to "ja"
  end

  it "processes default metadata" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~"INPUT", *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
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
    INPUT
    output = <<~OUTPUT
      <jis-standard type="semantic" version="#{Metanorma::JIS::VERSION}" xmlns="https://www.metanorma.org/ns/jis">
               <bibdata type="standard">
           <title language="en" format="text/plain" type="main">Introduction — Main Title — Title — Title Part</title>
           <title language="en" format="text/plain" type="title-intro">Introduction</title>
           <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
           <title language="en" format="text/plain" type="title-part">Title Part</title>
           <title language="ja" format="text/plain" type="main">Introduction Française — Titre Principal — Part du Titre</title>
           <title language="ja" format="text/plain" type="title-intro">Introduction Française</title>
           <title language="ja" format="text/plain" type="title-main">Titre Principal</title>
           <title language="ja" format="text/plain" type="title-part">Part du Titre</title>
           <docidentifier type="ISO">ISO/WD 1000-1.3</docidentifier>
           <docidentifier type="iso-reference">ISO/WD 1000-1.3:2000()</docidentifier>
           <docidentifier type="URN">urn:iso:std:iso:1000:-1:stage-20.20.v3:ja</docidentifier>
           <docidentifier type="iso-undated">ISO/WD 1000-1.3</docidentifier>
           <docidentifier type="iso-with-lang">ISO/WD 1000-1.3(ja)</docidentifier>
           <docnumber>1000</docnumber>
           <contributor>
             <role type="author"/>
             <organization>
               <name>Japanese Industrial Standards</name>
               <abbreviation>JIS</abbreviation>
             </organization>
           </contributor>
           <contributor>
             <role type="publisher"/>
             <organization>
               <name>Japanese Industrial Standards</name>
               <abbreviation>JIS</abbreviation>
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
             <stage abbreviation="WD">20</stage>
             <substage>20</substage>
             <iteration>3</iteration>
           </status>
           <copyright>
             <from>2000</from>
             <owner>
               <organization>
                 <name>Japanese Industrial Standards</name>
                 <abbreviation>JIS</abbreviation>
               </organization>
             </owner>
           </copyright>
           <ext>
             <doctype>standard</doctype>
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
               <project-number part="1">JIS 1000</project-number>
             </structuredidentifier>
             <stagename abbreviation="WD">Working Draft International Standard</stagename>
           </ext>
         </bibdata>
         <sections> </sections>
       </jis-standard>
    OUTPUT
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(xmlpp(strip_guid(xml.to_xml)))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes metadata, expert commentary" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~"INPUT", *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
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
          <jis-standard xmlns="https://www.metanorma.org/ns/jis" type="semantic" version="0.0.1">
        <bibdata type="standard">
          <title language="en" format="text/plain" type="main">Introduction — Main Title — Title — Title Part</title>
          <title language="en" format="text/plain" type="title-intro">Introduction</title>
          <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
          <title language="en" format="text/plain" type="title-part">Title Part</title>
          <title language="ja" format="text/plain" type="main">Introduction Française — Titre Principal — Part du Titre</title>
          <title language="ja" format="text/plain" type="title-intro">Introduction Française</title>
          <title language="ja" format="text/plain" type="title-main">Titre Principal</title>
          <title language="ja" format="text/plain" type="title-part">Part du Titre</title>
          <docidentifier type="ISO">Alternative Publisher/WD 1000-1.3</docidentifier>
          <docidentifier type="iso-reference">Alternative Publisher/WD 1000-1.3:2000()</docidentifier>
          <docidentifier type="URN">urn:iso:std:alternative publisher:1000:-1:stage-20.20.v3:ja</docidentifier>
          <docidentifier type="iso-undated">Alternative Publisher/WD 1000-1.3</docidentifier>
          <docidentifier type="iso-with-lang">Alternative Publisher/WD 1000-1.3(ja)</docidentifier>
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
            <stage abbreviation="WD">20</stage>
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
              <project-number part="1">Alternative Publisher 1000</project-number>
            </structuredidentifier>
            <stagename abbreviation="WD">Working Draft International Standard</stagename>
          </ext>
        </bibdata>
        <sections> </sections>
      </jis-standard>
    OUTPUT
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(xmlpp(strip_guid(xml.to_xml)))
      .to be_equivalent_to xmlpp(output)
  end
end
